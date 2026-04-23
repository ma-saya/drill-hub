'use client'

import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import Link from 'next/link'
import { useParams } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import {
  compareProblemsByListOrder,
  LEGACY_JAVA_TECHNOLOGY,
  findLocalProblem,
  loadLocalStudyRecord,
  mergeWithLocalProblems,
  saveLocalStudyRecord,
  type ProblemRecord,
  type ThemeRelation,
} from '@/lib/problemBank'
import CodeEditor from '@/components/CodeEditor/CodeEditor'
import styles from './detail.module.css'

type ProblemDetailRecord = ProblemRecord
const PROBLEM_NAV_CONTEXT_KEY = 'problem-nav-context-v1'
const RANDOM_NEXT_MODE_KEY = 'problem-random-next-mode-v1'
const MEMO_SAVE_MODE_KEY = 'problem-memo-save-mode-v1'
const EDITOR_DEFAULT_HEIGHT = 420
const EDITOR_MIN_HEIGHT = 280
const EDITOR_MAX_HEIGHT = 760
const EDITOR_MIN_WIDTH = 360
const EDITOR_MAX_WIDTH = 980

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
  return '記述'
}

const LEGACY_MANUAL_CODE_PREFIX = '__MANUAL_SAVE__\n'
const MANUAL_STUDY_CONTENT_PREFIX = '__MANUAL_STUDY_CONTENT__\n'

type SavedStudyContent = {
  code: string
  memo: string
}

type NavigableProblem = {
  id: ProblemRecord['id']
  title: ProblemRecord['title']
  level: ProblemRecord['level']
  type: ProblemRecord['type']
  theme_id: ProblemRecord['theme_id']
  themes?: ThemeRelation
  display_order?: number
}

const formatJavaLikeCode = (source: string) => {
  const lines = source.replace(/\r\n/g, '\n').split('\n')
  let indentLevel = 0

  return lines
    .map((line) => {
      const trimmed = line.trim()
      if (!trimmed) return ''

      const leadingClosings = (trimmed.match(/^}+/)?.[0].length ?? 0)
      indentLevel = Math.max(0, indentLevel - leadingClosings)

      const formattedLine = `${'    '.repeat(indentLevel)}${trimmed}`
      const openCount = (trimmed.match(/\{/g) ?? []).length
      const closeCount = (trimmed.match(/\}/g) ?? []).length
      indentLevel = Math.max(0, indentLevel + openCount - Math.max(0, closeCount - leadingClosings))

      return formattedLine
    })
    .join('\n')
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
  const contentWrapperRef = useRef<HTMLDivElement | null>(null)
  const editorAreaRef = useRef<HTMLDivElement | null>(null)
  const editorStickyPanelRef = useRef<HTMLDivElement | null>(null)
  const saveStatusTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const editorResizeStartRef = useRef<{
    pointerX: number
    pointerY: number
    width: number
    height: number
    maxWidth: number
  } | null>(null)
  const [returnTechnology, setReturnTechnology] = useState<string | null>(null)
  const [returnLevel, setReturnLevel] = useState<string | null>(null)
  const [returnStatus, setReturnStatus] = useState<string | null>(null)
  const [navigationProblemIds, setNavigationProblemIds] = useState<string[] | null>(null)
  const [isRandomNextMode, setIsRandomNextMode] = useState(false)
  const [randomNextProblemId, setRandomNextProblemId] = useState<string | null>(null)

  const [problem, setProblem] = useState<ProblemDetailRecord | null>(null)
  const [problemSequence, setProblemSequence] = useState<NavigableProblem[]>([])
  const [loading, setLoading] = useState(true)
  const [code, setCode] = useState('')
  const [savedCode, setSavedCode] = useState('')
  const [memo, setMemo] = useState('')
  const [savedMemo, setSavedMemo] = useState('')
  const [isMemoAutoSave, setIsMemoAutoSave] = useState(true)
  const [showAnswer, setShowAnswer] = useState(false)
  const [editorHeight, setEditorHeight] = useState(EDITOR_DEFAULT_HEIGHT)
  const [editorWidth, setEditorWidth] = useState<number | null>(null)
  
  const [assessment, setAssessment] = useState<string | null>(null)
  const [isWeak, setIsWeak] = useState(false)
  const [saveStatus, setSaveStatus] = useState<string | null>(null)
  const [userId, setUserId] = useState<string | null>(null)
  const [editorPanelHeight, setEditorPanelHeight] = useState<number | null>(null)
  const [editorDockMode, setEditorDockMode] = useState<'static' | 'fixed'>('static')
  const [editorDockStyle, setEditorDockStyle] = useState<React.CSSProperties>({})
  
  const [checkResult, setCheckResult] = useState<{ isCorrect: boolean, message: string } | null>(null)

  const showSaveStatus = useCallback((message: string, clearAfterMs?: number) => {
    if (saveStatusTimeoutRef.current) {
      clearTimeout(saveStatusTimeoutRef.current)
      saveStatusTimeoutRef.current = null
    }

    setSaveStatus(message)

    if (clearAfterMs) {
      saveStatusTimeoutRef.current = setTimeout(() => {
        setSaveStatus(null)
        saveStatusTimeoutRef.current = null
      }, clearAfterMs)
    }
  }, [])

  useEffect(() => {
    return () => {
      if (saveStatusTimeoutRef.current) {
        clearTimeout(saveStatusTimeoutRef.current)
      }
    }
  }, [])

  useEffect(() => {
    const handlePointerMove = (event: PointerEvent) => {
      if (!editorResizeStartRef.current) return

      const dragDistance = event.clientY - editorResizeStartRef.current.pointerY
      const dragWidthDistance = event.clientX - editorResizeStartRef.current.pointerX
      const nextHeight = editorResizeStartRef.current.height + dragDistance
      const nextWidth = editorResizeStartRef.current.width + dragWidthDistance
      setEditorHeight(Math.min(EDITOR_MAX_HEIGHT, Math.max(EDITOR_MIN_HEIGHT, nextHeight)))
      setEditorWidth(
        Math.min(
          editorResizeStartRef.current.maxWidth,
          Math.max(Math.min(EDITOR_MIN_WIDTH, editorResizeStartRef.current.maxWidth), nextWidth)
        )
      )
    }

    const handlePointerUp = () => {
      if (!editorResizeStartRef.current) return

      editorResizeStartRef.current = null
      document.body.style.cursor = ''
      document.body.style.userSelect = ''
    }

    window.addEventListener('pointermove', handlePointerMove)
    window.addEventListener('pointerup', handlePointerUp)

    return () => {
      window.removeEventListener('pointermove', handlePointerMove)
      window.removeEventListener('pointerup', handlePointerUp)
      document.body.style.cursor = ''
      document.body.style.userSelect = ''
    }
  }, [])
  
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

        const problemListResult = await supabase
          .from('problems')
          .select('id, title, level, type, theme_id, display_order, themes(name, technology_id, technologies(name, slug))')
          .order('display_order', { ascending: true })

        if (problemListResult.error) {
          const fallbackProblemListResult = await supabase
            .from('problems')
            .select('id, title, level, type, theme_id, display_order, themes(name)')
            .order('display_order', { ascending: true })

          if (fallbackProblemListResult.error) throw fallbackProblemListResult.error

          setProblemSequence(
            mergeWithLocalProblems((fallbackProblemListResult.data || []) as ProblemRecord[]) as NavigableProblem[]
          )
        } else {
          setProblemSequence(
            mergeWithLocalProblems((problemListResult.data || []) as ProblemRecord[]) as NavigableProblem[]
          )
        }

        // Start with an empty editor and only restore manually saved study content.
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

    const searchParams = new URLSearchParams(window.location.search)
    const technologyFromQuery = searchParams.get('technology')?.trim()
    const levelFromQuery = searchParams.get('level')?.trim()
    const statusFromQuery = searchParams.get('status')?.trim()

    setReturnTechnology(technologyFromQuery || null)
    setReturnLevel(levelFromQuery || null)
    setReturnStatus(statusFromQuery || null)
  }, [])

  useEffect(() => {
    if (typeof window === 'undefined') return

    setIsRandomNextMode(window.localStorage.getItem(RANDOM_NEXT_MODE_KEY) === 'on')
  }, [])

  useEffect(() => {
    if (typeof window === 'undefined') return

    setIsMemoAutoSave(window.localStorage.getItem(MEMO_SAVE_MODE_KEY) !== 'manual')
  }, [])

  const buildProblemsListHref = () => {
    const query: Record<string, string> = {}

    if (returnTechnology) query.technology = returnTechnology
    if (returnLevel) query.level = returnLevel
    if (returnStatus) query.status = returnStatus

    if (Object.keys(query).length === 0) {
      return '/problems'
    }

    return {
      pathname: '/problems',
      query,
    }
  }

  const buildNextProblemHref = (problemId: string) => {
    const query: Record<string, string> = {}

    if (returnTechnology) query.technology = returnTechnology
    if (returnLevel) query.level = returnLevel
    if (returnStatus) query.status = returnStatus

    if (Object.keys(query).length === 0) {
      return `/problems/${problemId}`
    }

    return {
      pathname: `/problems/${problemId}`,
      query,
    }
  }

  useEffect(() => {
    if (typeof window === 'undefined') return

    try {
      const rawNavigationContext = window.sessionStorage.getItem(PROBLEM_NAV_CONTEXT_KEY)
      if (!rawNavigationContext) {
        setNavigationProblemIds(null)
        return
      }

      const parsedNavigationContext = JSON.parse(rawNavigationContext)
      if (!Array.isArray(parsedNavigationContext?.problemIds)) {
        setNavigationProblemIds(null)
        return
      }

      const validProblemIds = parsedNavigationContext.problemIds.filter(
        (problemId: unknown): problemId is string => typeof problemId === 'string'
      )

      setNavigationProblemIds(validProblemIds)
    } catch {
      setNavigationProblemIds(null)
    }
  }, [id])

  const theme = getThemeRecord(problem?.themes)
  const technology = getTechnologyRecord(problem?.themes)
  const navigationProblemOrder = useMemo(
    () =>
      navigationProblemIds && navigationProblemIds.includes(id)
        ? new Map(navigationProblemIds.map((problemId, index) => [problemId, index]))
        : null,
    [id, navigationProblemIds]
  )
  const navigableProblems = useMemo(
    () =>
      navigationProblemOrder
        ? problemSequence
            .filter((candidate) => navigationProblemOrder.has(candidate.id))
            .sort((a, b) => (navigationProblemOrder.get(a.id) ?? 0) - (navigationProblemOrder.get(b.id) ?? 0))
        : problemSequence
            .filter((candidate) => {
              if (!returnTechnology) return true

              const candidateTechnology = getTechnologyRecord(candidate.themes)
              return candidateTechnology?.slug === returnTechnology
            })
            .sort(compareProblemsByListOrder),
    [navigationProblemOrder, problemSequence, returnTechnology]
  )
  const currentProblemIndex = navigableProblems.findIndex((candidate) => candidate.id === id)
  const previousProblem =
    currentProblemIndex > 0
      ? navigableProblems[currentProblemIndex - 1]
      : null
  const sequentialNextProblem =
    currentProblemIndex >= 0 && currentProblemIndex < navigableProblems.length - 1
      ? navigableProblems[currentProblemIndex + 1]
      : null
  const randomCandidateProblems = useMemo(
    () => navigableProblems.filter((candidate) => candidate.id !== id),
    [id, navigableProblems]
  )
  const randomCandidateSignature = randomCandidateProblems.map((candidate) => candidate.id).join(',')
  const randomNextProblem = randomNextProblemId
    ? randomCandidateProblems.find((candidate) => candidate.id === randomNextProblemId) ?? null
    : null
  const nextProblem = isRandomNextMode ? randomNextProblem : sequentialNextProblem
  const canNavigateToAnotherProblem = Boolean(previousProblem) || Boolean(sequentialNextProblem) || randomCandidateProblems.length > 0
  const isFillBlank = problem?.type === 'fill_blank'
  const canAutoCheck = isFillBlank
  const inputLabel = isFillBlank ? '空欄の答え' : 'あなたのコード'
  const isLocalProblem = problem?.id.startsWith('local-') ?? false
  const editorLanguage =
    technology?.slug === 'java' || technology?.slug === 'spring-boot' ? 'java' : 'plain'
  const inputPlaceholder = isFillBlank
    ? '空欄に入る答えだけを入力してください'
    : 'ここにコードを書いてください'
  const editorPanelStyle: React.CSSProperties = {
    ...editorDockStyle,
    ...(editorWidth ? { width: `${editorWidth}px` } : {}),
  }

  const handleCodeChange = (val: string) => {
    setCode(val)
    setCheckResult(null)
    setSaveStatus(null)
  }

  const handleMemoChange = (val: string) => {
    setMemo(val)
    setSaveStatus(null)
  }

  const handleEditorResizeStart = (event: React.PointerEvent<HTMLButtonElement>) => {
    event.preventDefault()
    const editorPanelRect = editorStickyPanelRef.current?.getBoundingClientRect()
    const currentWidth = editorPanelRect?.width ?? editorAreaRef.current?.getBoundingClientRect().width ?? 0
    const availableWidth = editorPanelRect ? window.innerWidth - editorPanelRect.left - 16 : currentWidth
    const maxWidth = Math.max(currentWidth, Math.min(EDITOR_MAX_WIDTH, availableWidth))

    editorResizeStartRef.current = {
      pointerX: event.clientX,
      pointerY: event.clientY,
      width: currentWidth,
      height: editorHeight,
      maxWidth,
    }
    document.body.style.cursor = 'nwse-resize'
    document.body.style.userSelect = 'none'
  }

  const handleToggleRandomNextMode = () => {
    const nextMode = !isRandomNextMode
    setIsRandomNextMode(nextMode)

    if (typeof window !== 'undefined') {
      window.localStorage.setItem(RANDOM_NEXT_MODE_KEY, nextMode ? 'on' : 'off')
    }
  }

  const handleMemoSaveModeChange = (shouldAutoSave: boolean) => {
    setIsMemoAutoSave(shouldAutoSave)
    setSaveStatus(null)

    if (typeof window !== 'undefined') {
      window.localStorage.setItem(MEMO_SAVE_MODE_KEY, shouldAutoSave ? 'auto' : 'manual')
    }
  }

  const handleAssessment = async (status: string) => {
    setAssessment(status)
    const didSave = await saveRecord(savedCode, memo, status, isWeak)
    if (didSave) {
      setSavedMemo(memo)
    }
  }

  const handleToggleWeak = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const weak = e.target.checked
    setIsWeak(weak)
    const didSave = await saveRecord(savedCode, memo, assessment, weak)
    if (didSave) {
      setSavedMemo(memo)
    }
  }

  const saveRecord = useCallback(async (
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
      showSaveStatus('ローカル保存しました', 2000)
      return true
    }

    if (!userId) {
      showSaveStatus('ログインしてください')
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
      showSaveStatus('保存しました', 2000)
      return true
    } catch (err) {
      console.error(err)
      showSaveStatus('保存に失敗しました')
      return false
    }
  }, [id, isLocalProblem, showSaveStatus, userId])

  useEffect(() => {
    if (loading || !problem) return
    if (!isMemoAutoSave) return
    if (memo === savedMemo) return

    let cancelled = false
    const timeoutId = setTimeout(() => {
      const memoToSave = memo

      showSaveStatus('メモを自動保存中...')
      void saveRecord(savedCode, memoToSave, assessment, isWeak).then((didSave) => {
        if (!cancelled && didSave) {
          setSavedMemo(memoToSave)
        }
      })
    }, 800)

    return () => {
      cancelled = true
      clearTimeout(timeoutId)
    }
  }, [assessment, isMemoAutoSave, isWeak, loading, memo, problem, saveRecord, savedCode, savedMemo, showSaveStatus])

  const handleSaveCode = async () => {
    const didSave = await saveRecord(code, memo, assessment, isWeak)
    if (didSave) {
      setSavedCode(code)
      setSavedMemo(memo)
    }
  }

  const handleSaveMemo = async () => {
    const didSave = await saveRecord(savedCode, memo, assessment, isWeak)
    if (didSave) {
      setSavedMemo(memo)
    }
  }

  const handleFormatCode = () => {
    if (editorLanguage !== 'java') return

    setCode(formatJavaLikeCode(code))
    setSaveStatus(null)
  }

  // Auto-check is only available for fill-in-the-blank problems.
  const checkCode = () => {
    if (!problem?.answer || !canAutoCheck) return
    const normalize = (str: string) => str.replace(/\s+/g, ' ').trim()
    
    const isCorrect = normalize(code) === normalize(problem.answer)
    if (isCorrect) {
      setCheckResult({ isCorrect: true, message: '正解です。とてもいいコードです。' })
      if (assessment !== 'success') {
         handleAssessment('success')
      }
    } else {
      setCheckResult({ isCorrect: false, message: '少し違います。解説や模範解答を見ながら、どこが違うか確認してみましょう。' })
    }
  }

  useEffect(() => {
    if (!isRandomNextMode) {
      setRandomNextProblemId(null)
      return
    }

    if (randomCandidateProblems.length === 0) {
      setRandomNextProblemId(null)
      return
    }

    const nextRandomProblem =
      randomCandidateProblems[Math.floor(Math.random() * randomCandidateProblems.length)]

    setRandomNextProblemId(nextRandomProblem.id)
  }, [id, isRandomNextMode, randomCandidateProblems, randomCandidateSignature])

  useEffect(() => {
    if (typeof window === 'undefined') return

    const contentWrapper = contentWrapperRef.current
    const editorArea = editorAreaRef.current
    const editorStickyPanel = editorStickyPanelRef.current

    const updateEditorDock = () => {
      if (!contentWrapper || !editorArea || !editorStickyPanel || window.innerWidth < 1024) {
        setEditorDockMode('static')
        setEditorDockStyle({})
        setEditorPanelHeight(null)
        return
      }

      const headerHeight = document.querySelector('header')?.getBoundingClientRect().height ?? 0
      const topOffset = headerHeight + 24
      const editorAreaRect = editorArea.getBoundingClientRect()
      const editorPanelRect = editorStickyPanel.getBoundingClientRect()
      const nextPanelHeight = Math.ceil(editorPanelRect.height)

      setEditorPanelHeight((currentHeight) => currentHeight === nextPanelHeight ? currentHeight : nextPanelHeight)

      if (editorAreaRect.top > topOffset) {
        setEditorDockMode('static')
        setEditorDockStyle({})
        return
      }

      setEditorDockMode('fixed')
      setEditorDockStyle({
        top: `${topOffset}px`,
        left: `${editorAreaRect.left}px`,
        width: `${editorAreaRect.width}px`,
      })
    }

    updateEditorDock()

    let frameId: number | null = null
    const scheduleUpdate = () => {
      if (frameId !== null) {
        window.cancelAnimationFrame(frameId)
      }

      frameId = window.requestAnimationFrame(() => {
        updateEditorDock()
        frameId = null
      })
    }

    window.addEventListener('scroll', scheduleUpdate, { passive: true })
    window.addEventListener('resize', scheduleUpdate)

    const resizeObserver = new ResizeObserver(scheduleUpdate)
    resizeObserver.observe(document.body)
    if (contentWrapper) resizeObserver.observe(contentWrapper)
    if (editorArea) resizeObserver.observe(editorArea)
    if (editorStickyPanel) resizeObserver.observe(editorStickyPanel)

    return () => {
      if (frameId !== null) {
        window.cancelAnimationFrame(frameId)
      }

      window.removeEventListener('scroll', scheduleUpdate)
      window.removeEventListener('resize', scheduleUpdate)
      resizeObserver.disconnect()
    }
  }, [showAnswer, checkResult, saveStatus, inputLabel, inputPlaceholder, editorLanguage])

  if (loading) return <div className={styles.container}>読み込み中...</div>
  if (!problem) return <div className={styles.container}>問題が見つかりません。</div>

  return (
    <div className={styles.container}>
      <Link
        href={buildProblemsListHref()}
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

      <div className={styles.contentWrapper} ref={contentWrapperRef}>
        <div className="animate-fade-in" style={{ animationDelay: '0.1s' }}>
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>問題文</h2>
            <div className={styles.statement}>{problem.statement}</div>
            
            {problem.requirements && (
              <>
                <h3 style={{ fontSize: '1rem', marginTop: '1rem', marginBottom: '0.5rem' }}>要件</h3>
                <div style={{ whiteSpace: 'pre-wrap', lineHeight: 1.6, padding: '1rem', backgroundColor: 'rgba(0,0,0,0.2)', borderRadius: '4px' }}>
                  {problem.requirements}
                </div>
              </>
            )}
            
            {problem.hint && (
              <details style={{ marginTop: '1rem' }}>
                <summary style={{ cursor: 'pointer', color: 'var(--primary)', fontWeight: 'bold' }}>ヒントを見る</summary>
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
                    答えを確認する
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
                    ? '穴埋め問題は、空欄に入る答えだけを入力して確認してください。'
                    : '記述問題は自分で考えてから、必要なら模範解答を見て学べる形にしています。'}
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
                  <h3 style={{ fontSize: '1rem', marginBottom: '0.5rem' }}>解説</h3>
                  <div style={{ lineHeight: '1.6', color: '#e2e8f0' }}>{problem.explanation}</div>
                </div>
              )}
              
              {problem.common_mistakes && (
                <div style={{ marginTop: '1.5rem', backgroundColor: 'rgba(239, 68, 68, 0.1)', padding: '1rem', borderRadius: '4px' }}>
                  <h3 style={{ fontSize: '1rem', marginBottom: '0.5rem', color: '#f87171' }}>よくあるミス</h3>
                  <div>{problem.common_mistakes}</div>
                </div>
              )}

              <div className={styles.memoSection}>
                <div className={styles.memoHeader}>
                  <h3 className={styles.memoTitle}>メモ</h3>
                  <div className={styles.memoModeTabs} aria-label="メモの保存方法">
                    <button
                      type="button"
                      className={`${styles.memoModeButton} ${isMemoAutoSave ? styles.memoModeButtonActive : ''}`}
                      onClick={() => handleMemoSaveModeChange(true)}
                      aria-pressed={isMemoAutoSave}
                    >
                      自動保存
                    </button>
                    <button
                      type="button"
                      className={`${styles.memoModeButton} ${!isMemoAutoSave ? styles.memoModeButtonActive : ''}`}
                      onClick={() => handleMemoSaveModeChange(false)}
                      aria-pressed={!isMemoAutoSave}
                    >
                      普通の保存
                    </button>
                  </div>
                </div>
                <textarea
                  className={styles.memoTextarea}
                  value={memo}
                  onChange={(e) => handleMemoChange(e.target.value)}
                  placeholder="解説でわからなかったことや、あとで見返したいポイントを書けます"
                />
                <div className={styles.actionRow}>
                  <span className={styles.memoHint}>
                    {isMemoAutoSave
                      ? memo === savedMemo
                        ? 'メモは自動保存済みです。'
                        : '入力が止まると自動保存します。'
                      : memo === savedMemo
                        ? 'メモは保存済みです。'
                        : '未保存のメモがあります。保存すると残せます。'}
                  </span>
                  {!isMemoAutoSave && (
                    <button type="button" className={styles.button} onClick={handleSaveMemo}>
                      保存
                    </button>
                  )}
                </div>
              </div>

              <div className={styles.selfAssessment}>
                <h3 style={{ fontSize: '1rem', textAlign: 'center' }}>自己評価を記録する</h3>
                <div className={styles.assessmentButtons}>
                  <button 
                    className={`${styles.button} ${styles.btnSuccess} ${assessment === 'success' ? styles.active : ''}`}
                    onClick={() => handleAssessment('success')}
                  >
                    できた
                  </button>
                  <button 
                    className={`${styles.button} ${styles.btnClose} ${assessment === 'close' ? styles.active : ''}`}
                    onClick={() => handleAssessment('close')}
                  >
                    惜しい
                  </button>
                  <button 
                    className={`${styles.button} ${styles.btnFail} ${assessment === 'fail' ? styles.active : ''}`}
                    onClick={() => handleAssessment('fail')}
                  >
                    できなかった
                  </button>
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

              {canNavigateToAnotherProblem && (
                <div className={styles.nextProblemRow}>
                  {previousProblem && (
                    <Link
                      href={buildNextProblemHref(previousProblem.id)}
                      className={`${styles.button} ${styles.nextProblemButton} ${styles.previousProblemButton}`}
                    >
                      前の問題へ
                    </Link>
                  )}
                  <button
                    type="button"
                    className={`${styles.randomToggleButton} ${isRandomNextMode ? styles.randomToggleButtonActive : ''}`}
                    onClick={handleToggleRandomNextMode}
                  >
                    ランダム: {isRandomNextMode ? 'ON' : 'OFF'}
                  </button>
                  {nextProblem && (
                    <Link
                      href={buildNextProblemHref(nextProblem.id)}
                      className={`${styles.button} ${styles.nextProblemButton}`}
                    >
                      {isRandomNextMode ? 'ランダムで次へ' : '次の問題へ'}
                    </Link>
                  )}
                </div>
              )}
            </div>
          )}
        </div>

        <div
          ref={editorAreaRef}
          className={styles.editorArea}
          style={{
            minHeight: editorPanelHeight ? `${editorPanelHeight}px` : undefined,
          }}
        >
          <div
            ref={editorStickyPanelRef}
            className={`${styles.editorStickyPanel} ${
              editorDockMode === 'fixed'
                ? styles.editorStickyPanelFixed
                : ''
            }`}
            style={editorPanelStyle}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
              <span style={{ fontWeight: 600 }}>{inputLabel}</span>
              {saveStatus && <span className={styles.saveMessage}>{saveStatus}</span>}
            </div>
            <div className={styles.editorFrame}>
              <CodeEditor
                value={code}
                onChange={handleCodeChange}
                placeholderText={inputPlaceholder}
                language={editorLanguage}
                minHeight={editorHeight}
              />
              <button
                type="button"
                className={styles.editorResizeHandle}
                onPointerDown={handleEditorResizeStart}
                aria-label="コード欄の大きさを変更"
              />
            </div>
            <div className={`${styles.actionRow} ${styles.editorActionRow}`}>
              <span className={styles.editorHint}>
                {code === savedCode
                  ? 'コードは自動保存されません。'
                  : '未保存のコードがあります。必要なら整えてから保存できます。'}
              </span>
              <div className={`${styles.actionButtons} ${styles.editorActionButtons}`}>
                {editorLanguage === 'java' && (
                  <button
                    type="button"
                    className={`${styles.button} ${styles.secondaryActionButton}`}
                    onClick={handleFormatCode}
                  >
                    整える
                  </button>
                )}
                <button
                  type="button"
                  className={`${styles.button} ${styles.primaryActionButton}`}
                  onClick={handleSaveCode}
                >
                  保存
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
