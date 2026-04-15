'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { supabase } from '@/lib/supabase'
import styles from './problems.module.css'

type Problem = {
  id: string
  title: string
  level: number
  type: string
  theme_id: string
  themes: any // Supabaseの仕様に合わせてanyにし、配列エラーを回避
}

type StudyRecord = {
  problem_id: string
  self_assessment: string
  is_weak: boolean
}

export default function Problems() {
  const [problems, setProblems] = useState<Problem[]>([])
  const [records, setRecords] = useState<Record<string, StudyRecord>>({})
  const [loading, setLoading] = useState(true)
  const [filterLevel, setFilterLevel] = useState('all')
  const [filterStatus, setFilterStatus] = useState('all')

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    setLoading(true)
    try {
      // Get session
      const { data: { session } } = await supabase.auth.getSession()
      
      // Fetch problems
      const { data: problemsData, error: probError } = await supabase
        .from('problems')
        .select('id, title, level, type, theme_id, themes(name)')
        .order('display_order', { ascending: true })

      if (probError) throw probError
      setProblems(problemsData || [])

      // Fetch study records if logged in
      if (session) {
        const { data: recordsData, error: recError } = await supabase
          .from('study_records')
          .select('problem_id, self_assessment, is_weak')
          .eq('user_id', session.user.id)

        if (recError) throw recError
        
        const recMap: Record<string, StudyRecord> = {}
        recordsData?.forEach(r => {
          recMap[r.problem_id] = r
        })
        setRecords(recMap)
      }
    } catch (error) {
      console.error('Error fetching data:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredProblems = problems.filter(p => {
    // Level filter
    if (filterLevel !== 'all' && p.level.toString() !== filterLevel) return false
    
    // Status filter
    if (filterStatus === 'weak') {
      return records[p.id]?.is_weak === true
    } else if (filterStatus === 'unsolved') {
      return !records[p.id] || records[p.id].self_assessment !== 'success'
    } else if (filterStatus === 'solved') {
      return records[p.id]?.self_assessment === 'success'
    }
    return true
  })

  if (loading) {
    return <div className={styles.container}><p>読み込み中...</p></div>
  }

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>問題一覧</h1>
        
        <div className={styles.filterBar}>
          <select 
            className={styles.filterSelect}
            value={filterLevel}
            onChange={(e) => setFilterLevel(e.target.value)}
          >
            <option value="all">すべてのレベル</option>
            <option value="1">レベル 1 (基礎)</option>
            <option value="2">レベル 2 (実践)</option>
            <option value="3">レベル 3 (応用)</option>
          </select>

          <select 
            className={styles.filterSelect}
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
          >
            <option value="all">すべての状態</option>
            <option value="unsolved">未クリア</option>
            <option value="solved">クリア済み</option>
            <option value="weak">苦手のみ</option>
          </select>
        </div>
      </div>

      <div className={styles.grid}>
        {filteredProblems.map((problem) => {
          const record = records[problem.id]
          const isSolved = record?.self_assessment === 'success'
          const isWeak = record?.is_weak

          return (
            <Link href={`/problems/${problem.id}`} key={problem.id} className={`${styles.card} animate-fade-in`}>
              <div className={styles.cardHeader}>
                <h2 className={styles.cardTitle}>{problem.title}</h2>
              </div>
              
              <div className={styles.badgeGroup}>
                <span className={`${styles.badge} ${styles.badgeTheme}`}>
                  {problem.themes?.name || 'テーマ未設定'}
                </span>
                <span className={`${styles.badge} ${
                  problem.level === 1 ? styles.badgeLevel1 : 
                  problem.level === 2 ? styles.badgeLevel2 : styles.badgeLevel3
                }`}>
                  Lv.{problem.level}
                </span>
                <span className={styles.badge}>
                  {problem.type === 'fill_blank' ? '穴埋め' : '記述'}
                </span>
              </div>

              <div className={styles.statusIndicator}>
                {record?.self_assessment === 'success' ? (
                  <span className={styles.statusSolved}>✓ できた</span>
                ) : record?.self_assessment === 'close' ? (
                  <span style={{ color: '#f59e0b', fontWeight: 'bold' }}>△ 惜しい</span>
                ) : record?.self_assessment === 'fail' ? (
                  <span style={{ color: '#ef4444', fontWeight: 'bold' }}>× できなかった</span>
                ) : (
                  <span style={{ color: '#94a3b8' }}>未挑戦</span>
                )}
                {isWeak && <span className={styles.statusWeak}>⚠️ 苦手</span>}
              </div>
            </Link>
          )
        })}
      </div>
      
      {filteredProblems.length === 0 && (
        <p style={{ textAlign: 'center', marginTop: '3rem', color: '#94a3b8' }}>
          該当する問題が見つかりません。
        </p>
      )}
    </div>
  )
}
