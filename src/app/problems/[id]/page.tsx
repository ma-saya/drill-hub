'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useParams } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import {
  LEGACY_JAVA_TECHNOLOGY,
  findLocalProblem,
  loadLocalStudyRecord,
  saveLocalStudyRecord,
  type ProblemRecord,
  type ThemeRelation,
} from '@/lib/problemBank'
import styles from './detail.module.css'

type ProblemDetailRecord = ProblemRecord

const getThemeRecord = (themes: ThemeRelation) => Array.isArray(themes) ? (themes[0] ?? null) : (themes ?? null)
const getTechnologyRecord = (themes: ThemeRelation) => {
  const theme = getThemeRecord(themes)
  const technologies = theme?.technologies
  const technology = Array.isArray(technologies) ? (technologies[0] ?? null) : (technologies ?? null)

  if (!technology && theme?.name) return LEGACY_JAVA_TECHNOLOGY

  return technology
}

const getProblemTypeLabel = (type: string) => {
  if (type === 'fill_blank') return '穴埋め'
  return '通常記述'
}

const LEGACY_MANUAL_CODE_PREFIX = '__MANUAL_SAVE__\n'
const MANUAL_STUDY_CONTENT_PREFIX = '__MANUAL_STUDY_CONTENT__\n'

type SavedStudyContent = {
  code: string
  memo: string
}

const emptySavedStudyContent = (): SavedStudyContent => ({
  code: '',
  memo: '',
})

const decodeSavedStudyContent = (storedCode: string | null | undefined): SavedStudyContent => {
  if (!storedCode) return emptySavedStudyContent()

  if (storedCode.startsWith(MANUAL_STUDY_CONTENT_PREFIX)) {
    try {
      const parsed = JSON.parse(storedCode.slice(MANUAL_STUDY_CONTENT_PREFIX.length))

      return {
        code: typeof parsed?.code === 'string' ? parsed.code : '',
        memo: typeof parsed?.memo === 'string' ? parsed.memo : '',
      }
    } catch {
      return emptySavedStudyContent()
    }
  }

  if (storedCode.startsWith(LEGACY_MANUAL_CODE_PREFIX)) {
    return {
      code: storedCode.slice(LEGACY_MANUAL_CODE_PREFIX.length),
      memo: '',
    }
  }

  return emptySavedStudyContent()
}

const encodeSavedStudyContent = ({ code, memo }: SavedStudyContent) => {
  if (code.length === 0 && memo.length === 0) return ''
  return `${MANUAL_STUDY_CONTENT_PREFIX}${JSON.stringify({ code, memo })}`
}

export default function ProblemDetail() {
  const params = useParams()
  const id = params.id as string
  const [returnTechnology, setReturnTechnology] = useState<string | null>(null)

  const [problem, setProblem] = useState<ProblemDetailRecord | null>(null)
  const [loading, setLoading] = useState(true)
  const [code, setCode] = useState('')
  const [savedCode, setSavedCode] = useState('')
  const [memo, setMemo] = useState('')
  const [savedMemo, setSavedMemo] = useState('')
  const [showAnswer, setShowAnswer] = useState(false)
  
  const [assessment, setAssessment] = useState<string | null>(null)
  const [isWeak, setIsWeak] = useState(false)
  const [saveStatus, setSaveStatus] = useState<string | null>(null)
  const [userId, setUserId] = useState<string | null>(null)
  
  const [checkResult, setCheckResult] = useState<{ isCorrect: boolean, message: string } | null>(null)
  
  useEffect(() => {
    async function loadProblem() {
      setLoading(true)
      try {
        const { data: { session } } = await supabase.auth.getSession()
        const uId = session?.user?.id
        setUserId(uId || null)

        // Try the multi-technology schema first, then gracefully fall back.
        let probData: ProblemDetailRecord | null = null
        const localProblem = findLocalProblem(id)

        const detailedResult = await supabase
          .from('problems')
          .select('*, themes(name, technology_id, technologies(name, slug))')
          .eq('id', id)
          .single()

        if (detailedResult.error) {
          const fallbackResult = await supabase
            .from('problems')
            .select('*, themes(name)')
            .eq('id', id)
            .maybeSingle()

          if (fallbackResult.data) {
            probData = fallbackResult.data as ProblemDetailRecord
          } else if (localProblem) {
            probData = localProblem
          } else if (fallbackResult.error) {
            throw fallbackResult.error
          }
        } else {
          probData = detailedResult.data as ProblemDetailRecord
        }

        if (!probData && localProblem) {
          probData = localProblem
        }

        setProblem(probData)

        // 穴埋めは空欄だけを入力させる。全文を入れると判定が不安定になるため。
        const defaultCode = ''
        const defaultMemo = ''

        if (localProblem && localProblem.id === id) {
          const localRecord = loadLocalStudyRecord(id)
          const initialSavedContent = decodeSavedStudyContent(localRecord?.user_code)
          setCode(initialSavedContent.code || defaultCode)
          setSavedCode(initialSavedContent.code || defaultCode)
          setMemo(initialSavedContent.memo || defaultMemo)
          setSavedMemo(initialSavedContent.memo || defaultMemo)
          setAssessment(localRecord?.self_assessment ?? null)
          setIsWeak(localRecord?.is_weak ?? false)
          return
        }

        // Fetch study record if exists
        if (uId) {
          const { data: recData } = await supabase
            .from('study_records')
            .select('*')
            .eq('user_id', uId)
            .eq('problem_id', id)
            .maybeSingle()

          if (recData) {
            const initialSavedContent = decodeSavedStudyContent(recData.user_code)
            setCode(initialSavedContent.code || defaultCode)
            setSavedCode(initialSavedContent.code || defaultCode)
            setMemo(initialSavedContent.memo || defaultMemo)
            setSavedMemo(initialSavedContent.memo || defaultMemo)
            setAssessment(recData.self_assessment)
            setIsWeak(recData.is_weak)
          } else {
            setCode(defaultCode)
            setSavedCode(defaultCode)
            setMemo(defaultMemo)
            setSavedMemo(defaultMemo)
          }
        } else {
          setCode(defaultCode)
          setSavedCode(defaultCode)
          setMemo(defaultMemo)
          setSavedMemo(defaultMemo)
        }
      } catch (err) {
        console.error(err)
      } finally {
        setLoading(false)
      }
    }

    void loadProblem()
  }, [id])

  useEffect(() => {
    if (typeof window === 'undefined') return

    const technologyFromQuery = new URLSearchParams(window.location.search).get('technology')?.trim()
    setReturnTechnology(technologyFromQuery || null)
  }, [])

  const theme = getThemeRecord(problem?.themes)
  const technology = getTechnologyRecord(problem?.themes)
  const isFillBlank = problem?.type === 'fill_blank'
  const canAutoCheck = isFillBlank
  const inputLabel = isFillBlank ? '空欄の答え' : 'あなたのコード'
  const isLocalProblem = problem?.id.startsWith('local-') ?? false
  const inputPlaceholder = isFillBlank
    ? '空欄に入るコードやアノテーションだけを入力してください'
    : 'ここにコードを入力してください'

  // 自動保存ロジック
  const handleCodeChange = (val: string) => {
    setCode(val)
    setCheckResult(null)
    setSaveStatus(null)
  }

  const handleMemoChange = (val: string) => {
    setMemo(val)
    setSaveStatus(null)
  }

  // エディター入力補助（括弧の自動補完・Tab対応）
  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    const target = e.target as HTMLTextAreaElement
    const { selectionStart, selectionEnd, value } = target
    
    const pairs: Record<string, string> = {
      '(': ')',
      '{': '}',
      '[': ']',
      '"': '"',
      "'": "'",
    }

    if (pairs[e.key]) {
      e.preventDefault()
      const closingChar = pairs[e.key]
      const currentSelection = value.substring(selectionStart, selectionEnd)
      const newValue = value.substring(0, selectionStart) + e.key + currentSelection + closingChar + value.substring(selectionEnd)
      
      handleCodeChange(newValue)
      
      setTimeout(() => {
        target.selectionStart = target.selectionEnd = selectionStart + 1
      }, 0)
    } else if (e.key === 'Backspace' && selectionStart === selectionEnd && selectionStart > 0) {
      // セットで消す機能： () {} [] "" '' の間でのBackspaceなら両方消す
      const prevChar = value[selectionStart - 1]
      const nextChar = value[selectionStart]
      if (pairs[prevChar] && pairs[prevChar] === nextChar) {
        e.preventDefault()
        const newValue = value.substring(0, selectionStart - 1) + value.substring(selectionEnd + 1)
        handleCodeChange(newValue)
        setTimeout(() => {
          target.selectionStart = target.selectionEnd = selectionStart - 1
        }, 0)
      }
    } else if (e.key === 'Tab') {
      // Tabキーでスペース4つインデント
      e.preventDefault()
      const newValue = value.substring(0, selectionStart) + '    ' + value.substring(selectionEnd)
      handleCodeChange(newValue)
      setTimeout(() => {
        target.selectionStart = target.selectionEnd = selectionStart + 4
      }, 0)
    }
  }

  const handleAssessment = async (status: string) => {
    setAssessment(status)
    await saveRecord(savedCode, savedMemo, status, isWeak)
  }

  const handleToggleWeak = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const weak = e.target.checked
    setIsWeak(weak)
    await saveRecord(savedCode, savedMemo, assessment, weak)
  }

  const saveRecord = async (
    userCode: string,
    userMemo: string,
    selfAssess: string | null,
    weak: boolean
  ) => {
    if (isLocalProblem) {
      saveLocalStudyRecord(id, {
        user_code: encodeSavedStudyContent({ code: userCode, memo: userMemo }),
        self_assessment: selfAssess,
        is_weak: weak,
        last_studied_at: new Date().toISOString(),
      })
      setSaveStatus('ローカル保存しました')
      setTimeout(() => setSaveStatus(null), 2000)
      return true
    }

    if (!userId) {
      setSaveStatus('ログインしてください')
      return false
    }
    
    try {
      const { error } = await supabase
        .from('study_records')
        .upsert({
          user_id: userId,
          problem_id: id,
          user_code: encodeSavedStudyContent({ code: userCode, memo: userMemo }),
          self_assessment: selfAssess,
          is_weak: weak,
          last_studied_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,problem_id'
        })

      if (error) throw error
      setSaveStatus('保存しました')
      setTimeout(() => setSaveStatus(null), 2000)
      return true
    } catch (err) {
      console.error(err)
      setSaveStatus('保存に失敗しました')
      return false
    }
  }

  const handleSaveCode = async () => {
    const didSave = await saveRecord(code, savedMemo, assessment, isWeak)
    if (didSave) {
      setSavedCode(code)
    }
  }

  const handleSaveMemo = async () => {
    const didSave = await saveRecord(savedCode, memo, assessment, isWeak)
    if (didSave) {
      setSavedMemo(memo)
    }
  }

  // 正誤判定ロジック
  const checkCode = () => {
    if (!problem?.answer || !canAutoCheck) return
    const normalize = (str: string) => str.replace(/\s+/g, ' ').trim()
    
    const isCorrect = normalize(code) === normalize(problem.answer)
    if (isCorrect) {
      setCheckResult({ isCorrect: true, message: '🎉 正解です！完璧なコードです！' })
      if (assessment !== 'success') {
         handleAssessment('success')
      }
    } else {
      setCheckResult({ isCorrect: false, message: '🤔 少し違います。模範解答と見比べてみましょう。（※変数名等の違いによる判定ミスの可能性もあります）' })
    }
  }

  if (loading) return <div className={styles.container}>読み込み中...</div>
  if (!problem) return <div className={styles.container}>問題が見つかりません。</div>

  return (
    <div className={styles.container}>
      <Link
        href={
          returnTechnology
            ? { pathname: '/problems', query: { technology: returnTechnology } }
            : '/problems'
        }
        className={styles.backLink}
      >
        ← 問題一覧に戻る
      </Link>
      
      <div className={`${styles.header} animate-fade-in`}>
        <div className={styles.badgeGroup}>
          {technology?.name && <span className={styles.badge}>{technology.name}</span>}
          <span className={styles.badge}>{theme?.name || 'テーマ未設定'}</span>
          <span className={styles.badge}>Lv.{problem.level}</span>
          <span className={styles.badge}>{getProblemTypeLabel(problem.type)}</span>
        </div>
        <h1 className={styles.title}>{problem.title}</h1>
      </div>

      <div className={styles.contentWrapper}>
        <div className="animate-fade-in" style={{ animationDelay: '0.1s' }}>
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>問題文</h2>
            <div className={styles.statement}>{problem.statement}</div>
            
            {problem.requirements && (
              <>
                <h3 style={{ fontSize: '1rem', marginTop: '1rem', marginBottom: '0.5rem' }}>🎯 要件</h3>
                <div style={{ whiteSpace: 'pre-wrap', lineHeight: 1.6, padding: '1rem', backgroundColor: 'rgba(0,0,0,0.2)', borderRadius: '4px' }}>
                  {problem.requirements}
                </div>
              </>
            )}
            
            {problem.hint && (
              <details style={{ marginTop: '1rem' }}>
                <summary style={{ cursor: 'pointer', color: 'var(--primary)', fontWeight: 'bold' }}>💡 ヒントを見る</summary>
                <div style={{ marginTop: '0.5rem', padding: '1rem', backgroundColor: 'rgba(255,255,255,0.05)', borderRadius: '4px' }}>
                  {problem.hint}
                </div>
              </details>
            )}
          </div>

          {!showAnswer ? (
             <div className={styles.section} style={{ textAlign: 'center' }}>
               {canAutoCheck && (
                 <button 
                   className={styles.button} 
                   style={{ backgroundColor: 'var(--primary)', color: 'white', marginRight: '1rem' }}
                   onClick={checkCode}
                 >
                   ✅ 空欄の答えを判定する
                 </button>
               )}
                <button 
                  className={styles.button} 
                  style={{ backgroundColor: 'var(--secondary)', color: 'white', border: '1px solid var(--border)' }}
                  onClick={() => setShowAnswer(true)}
                >
                  模範解答を見る
                </button>
                <div className={styles.helperText}>
                  {canAutoCheck
                    ? '穴埋め問題は空欄に入る答えだけを入力してください。'
                    : '通常記述問題は自動判定せず、模範解答を見ながら落ち着いて比べられる形にしています。'}
                </div>
                {isLocalProblem && (
                  <div className={styles.helperText}>
                    この追加問題セットは、いまはローカル保存で使える状態にしています。
                  </div>
                )}
                {checkResult && (
                  <div style={{ 
                    marginTop: '1rem', 
                   padding: '1rem', 
                   borderRadius: '4px',
                   backgroundColor: checkResult.isCorrect ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
                   color: checkResult.isCorrect ? '#34d399' : '#f87171'
                 }}>
                   {checkResult.message}
                 </div>
               )}
             </div>
          ) : (
            <div className={`${styles.section} ${styles.answerBox}`}>
              <h2 className={styles.sectionTitle}>模範解答</h2>
              <pre className={styles.pre}><code>{problem.answer}</code></pre>
              
              {problem.explanation && (
                <div style={{ marginTop: '1.5rem' }}>
                  <h3 style={{ fontSize: '1rem', marginBottom: '0.5rem' }}>📝 解説</h3>
                  <div style={{ lineHeight: '1.6', color: '#e2e8f0' }}>{problem.explanation}</div>
                </div>
              )}
              
              {problem.common_mistakes && (
                <div style={{ marginTop: '1.5rem', backgroundColor: 'rgba(239, 68, 68, 0.1)', padding: '1rem', borderRadius: '4px' }}>
                  <h3 style={{ fontSize: '1rem', marginBottom: '0.5rem', color: '#f87171' }}>⚠️ よくあるミス</h3>
                  <div>{problem.common_mistakes}</div>
                </div>
              )}

              <div className={styles.memoSection}>
                <h3 className={styles.memoTitle}>メモ</h3>
                <textarea
                  className={styles.memoTextarea}
                  value={memo}
                  onChange={(e) => handleMemoChange(e.target.value)}
                  placeholder="解説でわからなかったことや、あとで見返したいポイントを書けます"
                />
                <div className={styles.actionRow}>
                  <span className={styles.memoHint}>
                    {memo === savedMemo
                      ? 'メモは自動保存されません。'
                      : '未保存のメモがあります。メモを保存すると残せます。'}
                  </span>
                  <button type="button" className={styles.button} onClick={handleSaveMemo}>
                    メモを保存
                  </button>
                </div>
              </div>

              <div className={styles.selfAssessment}>
                <h3 style={{ fontSize: '1rem', textAlign: 'center' }}>自己評価を記録する</h3>
                <div className={styles.assessmentButtons}>
                  <button 
                    className={`${styles.button} ${styles.btnSuccess} ${assessment === 'success' ? styles.active : ''}`}
                    onClick={() => handleAssessment('success')}
                  >できた</button>
                  <button 
                    className={`${styles.button} ${styles.btnClose} ${assessment === 'close' ? styles.active : ''}`}
                    onClick={() => handleAssessment('close')}
                  >惜しい</button>
                  <button 
                    className={`${styles.button} ${styles.btnFail} ${assessment === 'fail' ? styles.active : ''}`}
                    onClick={() => handleAssessment('fail')}
                  >できなかった</button>
                </div>

                <label className={styles.weakToggle}>
                  <input 
                    type="checkbox" 
                    checked={isWeak} 
                    onChange={handleToggleWeak} 
                  />
                  この問題を「苦手」に登録する
                </label>
              </div>
            </div>
          )}
        </div>

        <div className={`${styles.editorArea} animate-fade-in`} style={{ animationDelay: '0.2s' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
            <span style={{ fontWeight: 600 }}>{inputLabel}</span>
            {saveStatus && <span className={styles.saveMessage}>{saveStatus}</span>}
          </div>
          <textarea
            className={styles.textarea}
            value={code}
            onChange={(e) => handleCodeChange(e.target.value)}
            onKeyDown={handleKeyDown}
            spellCheck="false"
            placeholder={inputPlaceholder}
          />
          <div className={styles.actionRow}>
            <span style={{ color: '#cbd5e1', fontSize: '0.875rem' }}>
              {code === savedCode ? 'コードは自動保存されません。' : '未保存の変更があります。保存ボタンで残せます。'}
            </span>
            <button type="button" className={styles.button} onClick={handleSaveCode}>
              保存
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
