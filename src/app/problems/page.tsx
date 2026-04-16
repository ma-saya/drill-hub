'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { type Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import {
  LEGACY_JAVA_TECHNOLOGY,
  type ProblemRecord,
  type StudyRecordSummary,
  type ThemeRelation,
  loadLocalStudyRecordSummaries,
  mergeWithLocalProblems,
} from '@/lib/problemBank'
import styles from './problems.module.css'

const PINNED_TECHNOLOGIES_KEY = 'tech-drill-pinned-technologies-v1'

const getThemeRecord = (themes: ThemeRelation) =>
  Array.isArray(themes) ? (themes[0] ?? null) : (themes ?? null)

const getTechnologyRecord = (themes: ThemeRelation) => {
  const theme = getThemeRecord(themes)
  const technologies = theme?.technologies
  const technology = Array.isArray(technologies) ? (technologies[0] ?? null) : (technologies ?? null)

  if (!technology && theme?.name) return LEGACY_JAVA_TECHNOLOGY

  return technology
}

const getProblemTypeLabel = (type: string) => {
  if (type === 'fill_blank') return '穴埋め'
  if (type === 'code') return 'コード'
  if (type === 'procedure') return '手順'
  if (type === 'concept') return '理解'
  return '記述'
}

const getCompletionRate = (solvedCount: number, totalCount: number) => {
  if (totalCount === 0) return 0
  return Math.round((solvedCount / totalCount) * 100)
}

type Problem = {
  id: ProblemRecord['id']
  title: ProblemRecord['title']
  level: ProblemRecord['level']
  type: ProblemRecord['type']
  theme_id: ProblemRecord['theme_id']
  themes?: ThemeRelation
  display_order?: number
}

type TechnologyStats = {
  slug: string
  name: string
  totalCount: number
  solvedCount: number
  weakCount: number
  completionRate: number
}

export default function Problems() {
  const [problems, setProblems] = useState<Problem[]>([])
  const [records, setRecords] = useState<Record<string, StudyRecordSummary>>({})
  const [loading, setLoading] = useState(true)
  const [filterLevel, setFilterLevel] = useState('all')
  const [filterStatus, setFilterStatus] = useState('all')
  const [filterTechnology, setFilterTechnology] = useState('all')
  const [technologyQuery, setTechnologyQuery] = useState('')
  const [pinnedTechnologies, setPinnedTechnologies] = useState<string[]>([])
  const [hasLoadedPinnedTechnologies, setHasLoadedPinnedTechnologies] = useState(false)
  const [session, setSession] = useState<Session | null>(null)

  useEffect(() => {
    void fetchData()
  }, [])

  useEffect(() => {
    if (typeof window === 'undefined') return

    try {
      const savedPinnedTechnologies = window.localStorage.getItem(PINNED_TECHNOLOGIES_KEY)
      if (!savedPinnedTechnologies) return

      const parsedPinnedTechnologies = JSON.parse(savedPinnedTechnologies)
      if (Array.isArray(parsedPinnedTechnologies)) {
        setPinnedTechnologies(
          parsedPinnedTechnologies.filter((slug): slug is string => typeof slug === 'string')
        )
      }
    } catch (error) {
      console.error('Failed to load pinned technologies:', error)
    } finally {
      setHasLoadedPinnedTechnologies(true)
    }
  }, [])

  const fetchData = async () => {
    setLoading(true)
    try {
      const {
        data: { session: currentSession },
      } = await supabase.auth.getSession()
      setSession(currentSession)

      const enhancedProblemsResult = await supabase
        .from('problems')
        .select('id, title, level, type, theme_id, themes(name, technology_id, technologies(name, slug))')
        .order('display_order', { ascending: true })

      if (enhancedProblemsResult.error) {
        const fallbackProblemsResult = await supabase
          .from('problems')
          .select('id, title, level, type, theme_id, display_order, themes(name)')
          .order('display_order', { ascending: true })

        if (fallbackProblemsResult.error) throw fallbackProblemsResult.error
        setProblems(mergeWithLocalProblems((fallbackProblemsResult.data || []) as ProblemRecord[]))
      } else {
        setProblems(mergeWithLocalProblems((enhancedProblemsResult.data || []) as ProblemRecord[]))
      }

      const localRecordSummaries = loadLocalStudyRecordSummaries()
      if (currentSession) {
        const { data: recordsData, error: recordsError } = await supabase
          .from('study_records')
          .select('problem_id, self_assessment, is_weak')
          .eq('user_id', currentSession.user.id)

        if (recordsError) throw recordsError

        const recordMap: Record<string, StudyRecordSummary> = { ...localRecordSummaries }
        recordsData?.forEach((record) => {
          recordMap[record.problem_id] = record
        })
        setRecords(recordMap)

        // ログイン中はSupabaseから固定技術を取得してlocalStorageの値を上書き
        const { data: settingsData, error: settingsError } = await supabase
          .from('user_settings')
          .select('pinned_technologies')
          .eq('user_id', currentSession.user.id)
          .single()

        // PGRST116 = Row not found（新規ユーザーは正常）
        if (!settingsError || settingsError.code === 'PGRST116') {
          if (settingsData?.pinned_technologies && Array.isArray(settingsData.pinned_technologies)) {
            setPinnedTechnologies(settingsData.pinned_technologies)
          }
        }
      } else {
        setRecords(localRecordSummaries)
      }
    } catch (error) {
      console.error('Error fetching data:', error)
    } finally {
      setLoading(false)
    }
  }

  const technologyStatsMap = problems.reduce((map, problem) => {
    const technology = getTechnologyRecord(problem.themes)
    if (!technology?.slug || !technology?.name) return map

    const current = map.get(technology.slug) ?? {
      slug: technology.slug,
      name: technology.name,
      totalCount: 0,
      solvedCount: 0,
      weakCount: 0,
      completionRate: 0,
    }

    current.totalCount += 1
    if (records[problem.id]?.self_assessment === 'success') current.solvedCount += 1
    if (records[problem.id]?.is_weak) current.weakCount += 1
    current.completionRate = getCompletionRate(current.solvedCount, current.totalCount)

    map.set(technology.slug, current)
    return map
  }, new Map<string, TechnologyStats>())

  const technologyStats = Array.from(technologyStatsMap.values()).sort((a, b) =>
    (a.name ?? '').localeCompare(b.name ?? '', 'ja')
  )

  const technologyOptions = technologyStats

  useEffect(() => {
    // loading中はtechnologyOptionsがまだ空のため、固定が削除されないようスキップする
    if (!hasLoadedPinnedTechnologies || loading || typeof window === 'undefined') return

    const validTechnologySlugs = new Set(technologyOptions.map((technology) => technology.slug))
    const sanitizedPinnedTechnologies = pinnedTechnologies.filter((slug) => validTechnologySlugs.has(slug))

    if (sanitizedPinnedTechnologies.length !== pinnedTechnologies.length) {
      // 無効なslugを除去してから保存
      setPinnedTechnologies(sanitizedPinnedTechnologies)
      // 常にlocalStorageに保存（フォールバック）
      window.localStorage.setItem(PINNED_TECHNOLOGIES_KEY, JSON.stringify(sanitizedPinnedTechnologies))
      // ログイン中はSupabaseにも保存
      if (session) {
        void supabase.from('user_settings').upsert({
          user_id: session.user.id,
          pinned_technologies: sanitizedPinnedTechnologies,
          updated_at: new Date().toISOString(),
        }, { onConflict: 'user_id' })
      }
      return
    }

    // 常にlocalStorageに保存（ログイン中のSupabase保存はtoggle時に行う）
    window.localStorage.setItem(
      PINNED_TECHNOLOGIES_KEY,
      JSON.stringify(sanitizedPinnedTechnologies)
    )
  }, [hasLoadedPinnedTechnologies, loading, session, pinnedTechnologies, technologyOptions])

  const normalizedTechnologyQuery = technologyQuery.trim().toLowerCase()
  const visibleTechnologyOptions = technologyOptions.filter((technology) => {
    if (!normalizedTechnologyQuery) return true

    return (
      technology.name.toLowerCase().includes(normalizedTechnologyQuery) ||
      technology.slug.toLowerCase().includes(normalizedTechnologyQuery)
    )
  })

  const pinnedTechnologyOptions = pinnedTechnologies
    .map((slug) => technologyOptions.find((technology) => technology.slug === slug) ?? null)
    .filter((technology): technology is TechnologyStats => technology !== null)

  const togglePinnedTechnology = (slug: string) => {
    const next = pinnedTechnologies.includes(slug)
      ? pinnedTechnologies.filter((item) => item !== slug)
      : [...pinnedTechnologies, slug]

    setPinnedTechnologies(next)

    // 常にlocalStorageに保存（Supabaseが未準備でも壊れないフォールバック）
    if (typeof window !== 'undefined') {
      window.localStorage.setItem(PINNED_TECHNOLOGIES_KEY, JSON.stringify(next))
    }

    // ログイン中はSupabaseにも保存（別デバイスで同期するため）
    if (session) {
      void supabase.from('user_settings').upsert({
        user_id: session.user.id,
        pinned_technologies: next,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' })
    }
  }

  const filteredProblems = problems
    .filter((problem) => {
      const technology = getTechnologyRecord(problem.themes)

      if (filterTechnology !== 'all' && technology?.slug !== filterTechnology) return false
      if (filterLevel !== 'all' && problem.level.toString() !== filterLevel) return false

      if (filterStatus === 'weak') {
        return records[problem.id]?.is_weak === true
      }
      if (filterStatus === 'unattempted') {
        return !records[problem.id] || !records[problem.id].self_assessment
      }
      if (filterStatus === 'success') {
        return records[problem.id]?.self_assessment === 'success'
      }
      if (filterStatus === 'close') {
        return records[problem.id]?.self_assessment === 'close'
      }
      if (filterStatus === 'fail') {
        return records[problem.id]?.self_assessment === 'fail'
      }

      return true
    })
    .sort((a, b) => {
      if (a.level !== b.level) return a.level - b.level

      const orderA = a.display_order ?? Number.MAX_SAFE_INTEGER
      const orderB = b.display_order ?? Number.MAX_SAFE_INTEGER
      if (orderA !== orderB) return orderA - orderB

      return a.title.localeCompare(b.title, 'ja')
    })

  const totalProblemCount = problems.length
  const solvedProblemCount = problems.filter(
    (problem) => records[problem.id]?.self_assessment === 'success'
  ).length
  const weakProblemCount = problems.filter((problem) => records[problem.id]?.is_weak).length
  const overallCompletionRate = getCompletionRate(solvedProblemCount, totalProblemCount)

  const filteredSolvedCount = filteredProblems.filter(
    (problem) => records[problem.id]?.self_assessment === 'success'
  ).length
  const filteredCompletionRate = getCompletionRate(filteredSolvedCount, filteredProblems.length)

  const selectedTechnologyStats =
    filterTechnology === 'all'
      ? null
      : technologyOptions.find((technology) => technology.slug === filterTechnology) ?? null

  if (loading) {
    return (
      <div className={styles.container}>
        <p>読み込み中...</p>
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>問題一覧</h1>

        <div className={styles.progressOverview}>
          <div className={styles.progressCard}>
            <span className={styles.progressLabel}>全体の問題数</span>
            <strong className={styles.progressValue}>{totalProblemCount}問</strong>
            <span className={styles.progressMeta}>
              解けた数 {solvedProblemCount}問 / 達成率 {overallCompletionRate}%
            </span>
          </div>

          <div className={styles.progressCard}>
            <span className={styles.progressLabel}>現在の絞り込み</span>
            <strong className={styles.progressValue}>{filteredProblems.length}問</strong>
            <span className={styles.progressMeta}>
              解けた数 {filteredSolvedCount}問 / 達成率 {filteredCompletionRate}%
            </span>
          </div>

          <div className={styles.progressCard}>
            <span className={styles.progressLabel}>
              {selectedTechnologyStats ? `${selectedTechnologyStats.name} の進捗` : '苦手登録'}
            </span>
            <strong className={styles.progressValue}>
              {selectedTechnologyStats ? `${selectedTechnologyStats.totalCount}問` : `${weakProblemCount}問`}
            </strong>
            <span className={styles.progressMeta}>
              {selectedTechnologyStats
                ? `解けた数 ${selectedTechnologyStats.solvedCount}問 / 達成率 ${selectedTechnologyStats.completionRate}%`
                : `苦手にした問題 ${weakProblemCount}問`}
            </span>
          </div>
        </div>

        <div className={styles.filterBar}>
          <div className={styles.technologyFilterSection}>
            <div className={styles.filterSectionHeader}>
              <span className={styles.filterLabel}>技術</span>
              <input
                className={styles.searchInput}
                type="search"
                value={technologyQuery}
                onChange={(e) => setTechnologyQuery(e.target.value)}
                placeholder="技術名で検索"
                aria-label="技術名で検索"
              />
            </div>

            <div className={styles.pinnedRow}>
              <button
                type="button"
                className={`${styles.technologyChip} ${filterTechnology === 'all' ? styles.technologyChipActive : ''}`}
                onClick={() => setFilterTechnology('all')}
              >
                <span>すべての技術</span>
                <span className={styles.technologyMeta}>
                  {solvedProblemCount}/{totalProblemCount}問 ・ {overallCompletionRate}%
                </span>
              </button>
              {pinnedTechnologyOptions.map((technology) => (
                <button
                  key={`pinned-${technology.slug}`}
                  type="button"
                  className={`${styles.technologyChip} ${filterTechnology === technology.slug ? styles.technologyChipActive : ''}`}
                  onClick={() => setFilterTechnology(technology.slug)}
                >
                  <span>{technology.name}</span>
                  <span className={styles.technologyMeta}>
                    {technology.solvedCount}/{technology.totalCount}問 ・ {technology.completionRate}%
                  </span>
                </button>
              ))}
            </div>

            <div className={styles.technologyList}>
              {visibleTechnologyOptions.map((technology) => {
                const isPinned = pinnedTechnologies.includes(technology.slug)
                const isSelected = filterTechnology === technology.slug

                return (
                  <div key={technology.slug} className={styles.technologyItem}>
                    <button
                      type="button"
                      className={`${styles.technologyOptionButton} ${isSelected ? styles.technologyOptionButtonActive : ''}`}
                      onClick={() => setFilterTechnology(technology.slug)}
                    >
                      <span>{technology.name}</span>
                      <span className={styles.technologyMeta}>
                        {technology.totalCount}問 ・ 解けた数 {technology.solvedCount}問 ・ {technology.completionRate}%
                      </span>
                    </button>
                    <button
                      type="button"
                      className={`${styles.pinButton} ${isPinned ? styles.pinButtonActive : ''}`}
                      onClick={() => togglePinnedTechnology(technology.slug)}
                      aria-pressed={isPinned}
                    >
                      {isPinned ? '固定中' : '固定'}
                    </button>
                  </div>
                )
              })}

              {visibleTechnologyOptions.length === 0 && (
                <p className={styles.emptyTechnologyMessage}>検索に合う技術がありません。</p>
              )}
            </div>
          </div>

          <div className={styles.secondaryFilters}>
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
              <option value="unattempted">未学習</option>
              <option value="success">できた</option>
              <option value="close">惜しい</option>
              <option value="fail">できなかった</option>
              <option value="weak">苦手のみ</option>
            </select>
          </div>
        </div>
      </div>

      <div className={styles.grid}>
        {filteredProblems.map((problem) => {
          const record = records[problem.id]
          const isWeak = record?.is_weak
          const theme = getThemeRecord(problem.themes)
          const technology = getTechnologyRecord(problem.themes)

          return (
            <Link href={`/problems/${problem.id}`} key={problem.id} className={`${styles.card} animate-fade-in`}>
              <div className={styles.cardHeader}>
                <h2 className={styles.cardTitle}>{problem.title}</h2>
              </div>

              <div className={styles.badgeGroup}>
                {technology?.name && <span className={styles.badge}>{technology.name}</span>}
                <span className={`${styles.badge} ${styles.badgeTheme}`}>{theme?.name || 'テーマ未設定'}</span>
                <span
                  className={`${styles.badge} ${
                    problem.level === 1
                      ? styles.badgeLevel1
                      : problem.level === 2
                        ? styles.badgeLevel2
                        : styles.badgeLevel3
                  }`}
                >
                  Lv.{problem.level}
                </span>
                <span className={styles.badge}>{getProblemTypeLabel(problem.type)}</span>
              </div>

              <div className={styles.statusIndicator}>
                {record?.self_assessment === 'success' ? (
                  <span className={styles.statusSolved}>OK できた</span>
                ) : record?.self_assessment === 'close' ? (
                  <span style={{ color: '#f59e0b', fontWeight: 'bold' }}>もう少し</span>
                ) : record?.self_assessment === 'fail' ? (
                  <span style={{ color: '#ef4444', fontWeight: 'bold' }}>未達成</span>
                ) : (
                  <span style={{ color: '#94a3b8' }}>未学習</span>
                )}
                {isWeak && <span className={styles.statusWeak}>苦手</span>}
              </div>
            </Link>
          )
        })}
      </div>

      {filteredProblems.length === 0 && (
        <p style={{ textAlign: 'center', marginTop: '3rem', color: '#94a3b8' }}>
          条件に合う問題が見つかりません。
        </p>
      )}
    </div>
  )
}
