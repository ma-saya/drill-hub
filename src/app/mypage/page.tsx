'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { type User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import { DEFAULT_DAILY_GOAL, loadDailyGoal, saveDailyGoal } from '@/lib/userSettings'
import styles from './mypage.module.css'

function buildCalendarData(studiedDatesMap: Map<string, number>, weeks: number) {
  const cells: { date: Date; count: number }[][] = []
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const startDay = new Date(today)
  startDay.setDate(today.getDate() - today.getDay() - (weeks - 1) * 7)

  for (let weekIndex = 0; weekIndex < weeks; weekIndex += 1) {
    const week: { date: Date; count: number }[] = []
    for (let dayIndex = 0; dayIndex < 7; dayIndex += 1) {
      const date = new Date(startDay)
      date.setDate(startDay.getDate() + weekIndex * 7 + dayIndex)
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
      week.push({ date, count: studiedDatesMap.get(key) ?? 0 })
    }
    cells.push(week)
  }

  return cells
}

function getLevel(count: number) {
  if (count === 0) return 0
  if (count === 1) return 1
  if (count === 2) return 2
  if (count <= 4) return 3
  if (count <= 6) return 4
  return 5
}

export default function MyPage() {
  const router = useRouter()
  const [user, setUser] = useState<User | null>(null)
  const [isGuest, setIsGuest] = useState(false)
  const [stats, setStats] = useState({
    totalAttempted: 0,
    success: 0,
    close: 0,
    fail: 0,
    weak: 0,
    streak: 0,
  })
  const [calendarData, setCalendarData] = useState<{ date: Date; count: number }[][]>([])
  const [totalStudyDays, setTotalStudyDays] = useState(0)
  const [dailyGoal, setDailyGoal] = useState(DEFAULT_DAILY_GOAL)
  const [dailyGoalInput, setDailyGoalInput] = useState(String(DEFAULT_DAILY_GOAL))
  const [saveMessage, setSaveMessage] = useState<string | null>(null)
  const [isSavingGoal, setIsSavingGoal] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadData = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      const isGuestMode = localStorage.getItem('tech-drill-guest-mode') === 'true'

      if (!session && !isGuestMode) {
        router.push('/login')
        return
      }

      setUser(session?.user ?? null)
      setIsGuest(isGuestMode && !session)

      const loadedDailyGoal = await loadDailyGoal(session?.user?.id ?? null)
      setDailyGoal(loadedDailyGoal)
      setDailyGoalInput(String(loadedDailyGoal))

      let records: Array<{
        self_assessment?: string | null
        is_weak?: boolean
        last_studied_at: string
      }> = []

      if (session) {
        const { data } = await supabase
          .from('study_records')
          .select('*')
          .eq('user_id', session.user.id)

        records = (data ?? []) as typeof records
      } else if (isGuestMode) {
        const localData = localStorage.getItem('tech-drill-local-records-v1')
        if (localData) {
          try {
            const parsed = JSON.parse(localData)
            records = Object.values(parsed) as typeof records
          } catch (error) {
            console.error('Failed to parse local records', error)
          }
        }
      }

      setStats({
        totalAttempted: records.length,
        success: records.filter((record) => record.self_assessment === 'success').length,
        close: records.filter((record) => record.self_assessment === 'close').length,
        fail: records.filter((record) => record.self_assessment === 'fail').length,
        weak: records.filter((record) => record.is_weak).length,
        streak: 0,
      })

      const dateMap = new Map<string, number>()
      records.forEach((record) => {
        const studiedAt = new Date(record.last_studied_at)
        const key = `${studiedAt.getFullYear()}-${String(studiedAt.getMonth() + 1).padStart(2, '0')}-${String(studiedAt.getDate()).padStart(2, '0')}`
        dateMap.set(key, (dateMap.get(key) ?? 0) + 1)
      })
      setTotalStudyDays(dateMap.size)
      setCalendarData(buildCalendarData(dateMap, 18))

      const studiedDays = new Set(
        records.map((record) => {
          const studiedAt = new Date(record.last_studied_at)
          return `${studiedAt.getFullYear()}-${studiedAt.getMonth()}-${studiedAt.getDate()}`
        })
      )

      let streakCount = 0
      const currentDate = new Date()
      currentDate.setHours(0, 0, 0, 0)
      while (true) {
        const key = `${currentDate.getFullYear()}-${currentDate.getMonth()}-${currentDate.getDate()}`
        if (!studiedDays.has(key)) break
        streakCount += 1
        currentDate.setDate(currentDate.getDate() - 1)
      }

      setStats((prev) => ({ ...prev, streak: streakCount }))
      setLoading(false)
    }

    void loadData()
  }, [router])

  const handleSaveDailyGoal = async () => {
    setIsSavingGoal(true)
    setSaveMessage(null)

    const result = await saveDailyGoal(user?.id ?? null, Number.parseInt(dailyGoalInput, 10))
    setDailyGoal(result.goal)
    setDailyGoalInput(String(result.goal))
    setSaveMessage(result.savedRemotely ? '保存しました' : 'この端末に保存しました')
    setIsSavingGoal(false)
  }

  if (loading) return <div className={styles.container}>読み込み中...</div>
  if (!user && !isGuest) return null

  const DAYS = ['日', '月', '火', '水', '木', '金', '土']

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>マイページ</h1>

      <div className={`${styles.card} animate-fade-in`}>
        <div className={styles.userInfo}>
          <h2 style={{ color: '#94a3b8', fontSize: '1rem' }}>
            {user ? 'ログイン中のアカウント' : 'ゲストモード'}
          </h2>
          <div className={styles.email}>
            {user ? user.email : 'ゲストモードではブラウザに学習データを保存します'}
          </div>
        </div>

        <h2 className={styles.recentTitle}>学習サマリー</h2>
        <div className={styles.statsGrid}>
          <div className={styles.statItem}>
            <div className={styles.statValue} style={{ color: '#f59e0b' }}>🔥 {stats.streak}</div>
            <div className={styles.statLabel}>連続学習日数</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statValue}>{stats.totalAttempted}</div>
            <div className={styles.statLabel}>挑戦した問題数</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statValue} style={{ color: 'var(--accent)' }}>{stats.success}</div>
            <div className={styles.statLabel}>できた</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statValue} style={{ color: 'var(--warning)' }}>{stats.weak}</div>
            <div className={styles.statLabel}>苦手な問題</div>
          </div>
        </div>
      </div>

      <div className={`${styles.card} animate-fade-in`} style={{ animationDelay: '0.1s' }}>
        <h2 className={styles.recentTitle}>1日の目標</h2>
        <div className={styles.goalRow}>
          <div>
            <div className={styles.goalValue}>{dailyGoal}問</div>
            <div className={styles.goalHint}>
              ホームの「今日の目標問題数」に反映されます。
            </div>
          </div>
          <div className={styles.goalControls}>
            <input
              className={styles.goalInput}
              type="number"
              min="1"
              max="20"
              value={dailyGoalInput}
              onChange={(e) => setDailyGoalInput(e.target.value)}
            />
            <button
              type="button"
              className={styles.goalButton}
              onClick={handleSaveDailyGoal}
              disabled={isSavingGoal}
            >
              {isSavingGoal ? '保存中...' : '目標を保存'}
            </button>
          </div>
        </div>
        {saveMessage && <div className={styles.goalSaveMessage}>{saveMessage}</div>}
      </div>

      <div className={`${styles.card} animate-fade-in`} style={{ animationDelay: '0.15s' }}>
        <h2 className={styles.calendarTitle}>学習カレンダー（直近18週間）</h2>
        <div className={styles.calendarMeta}>
          合計 <strong>{totalStudyDays}</strong> 日学習しました
        </div>

        <div style={{ display: 'flex', gap: '3px', marginBottom: '3px' }}>
          <div style={{ width: '14px' }} />
          {DAYS.map((day) => (
            <div
              key={day}
              style={{ width: '14px', fontSize: '9px', color: '#64748b', textAlign: 'center' }}
            >
              {day}
            </div>
          ))}
        </div>

        <div className={styles.calendarGrid}>
          {calendarData.map((week, weekIndex) => (
            <div key={weekIndex} className={styles.calendarWeek}>
              {week.map((cell, dayIndex) => {
                const level = getLevel(cell.count)
                const dateText = `${cell.date.getMonth() + 1}/${cell.date.getDate()}`

                return (
                  <div
                    key={dayIndex}
                    className={styles.calendarCell}
                    data-level={level}
                    title={`${dateText}: ${cell.count}問`}
                  />
                )
              })}
            </div>
          ))}
        </div>

        <div className={styles.calendarLegend}>
          <span>少ない</span>
          {[0, 1, 2, 3, 4, 5].map((level) => (
            <div
              key={level}
              className={styles.legendCell}
              style={level > 0 ? {
                backgroundColor: ['#1d4ed8', '#2563eb', '#3b82f6', '#60a5fa', '#93c5fd'][level - 1],
                borderColor: ['#1d4ed8', '#2563eb', '#3b82f6', '#60a5fa', '#93c5fd'][level - 1],
              } : {}}
            />
          ))}
          <span>多い</span>
        </div>
      </div>

      <div className={styles.recentSection}>
        <Link href="/problems" style={{ color: 'var(--primary)', textDecoration: 'underline' }}>
          問題一覧へ戻る
        </Link>
      </div>
    </div>
  )
}
