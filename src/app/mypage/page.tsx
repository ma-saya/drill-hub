'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { type User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import styles from './mypage.module.css'

// 過去N週分のカレンダーデータを生成する
function buildCalendarData(studiedDatesMap: Map<string, number>, weeks: number) {
  const cells: { date: Date; count: number }[][] = []
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  // 今日を含む週の日曜日から始める
  const startDay = new Date(today)
  startDay.setDate(today.getDate() - today.getDay() - (weeks - 1) * 7)

  for (let w = 0; w < weeks; w++) {
    const week: { date: Date; count: number }[] = []
    for (let d = 0; d < 7; d++) {
      const date = new Date(startDay)
      date.setDate(startDay.getDate() + w * 7 + d)
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
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadData = async () => {
      const { data: { session } } = await supabase.auth.getSession()

      if (!session) {
        router.push('/login')
        return
      }

      setUser(session.user)

      const { data: records } = await supabase
        .from('study_records')
        .select('*')
        .eq('user_id', session.user.id)

      if (records) {
        setStats({
          totalAttempted: records.length,
          success: records.filter(r => r.self_assessment === 'success').length,
          close: records.filter(r => r.self_assessment === 'close').length,
          fail: records.filter(r => r.self_assessment === 'fail').length,
          weak: records.filter(r => r.is_weak).length,
          streak: 0,
        })

        // カレンダー用：日付ごとの学習数をマップ化
        const dateMap = new Map<string, number>()
        records.forEach(r => {
          const d = new Date(r.last_studied_at)
          const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
          dateMap.set(key, (dateMap.get(key) ?? 0) + 1)
        })
        setTotalStudyDays(dateMap.size)
        setCalendarData(buildCalendarData(dateMap, 18))

        // ストリーク計算
        const studiedDays = new Set(
          records.map(r => {
            const d = new Date(r.last_studied_at)
            return `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`
          })
        )
        let streakCount = 0
        const cur = new Date()
        cur.setHours(0, 0, 0, 0)
        while (true) {
          const key = `${cur.getFullYear()}-${cur.getMonth()}-${cur.getDate()}`
          if (studiedDays.has(key)) {
            streakCount++
            cur.setDate(cur.getDate() - 1)
          } else {
            break
          }
        }
        setStats(prev => ({ ...prev, streak: streakCount }))
      }

      setLoading(false)
    }

    loadData()
  }, [router])

  if (loading) return <div className={styles.container}>読み込み中...</div>
  if (!user) return null

  const DAYS = ['日', '月', '火', '水', '木', '金', '土']

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>マイページ</h1>

      <div className={`${styles.card} animate-fade-in`}>
        <div className={styles.userInfo}>
          <h2 style={{ color: '#94a3b8', fontSize: '1rem' }}>ログイン中のアカウント</h2>
          <div className={styles.email}>{user.email}</div>
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
            <div className={styles.statLabel}>クリア済み</div>
          </div>
          <div className={styles.statItem}>
            <div className={styles.statValue} style={{ color: 'var(--warning)' }}>{stats.weak}</div>
            <div className={styles.statLabel}>苦手な問題</div>
          </div>
        </div>
      </div>

      {/* 学習カレンダー */}
      <div className={`${styles.card} animate-fade-in`} style={{ animationDelay: '0.15s' }}>
        <h2 className={styles.calendarTitle}>📅 学習カレンダー（過去18週）</h2>
        <div className={styles.calendarMeta}>
          合計 <strong>{totalStudyDays}</strong> 日間学習しました
        </div>

        {/* 曜日ラベル */}
        <div style={{ display: 'flex', gap: '3px', marginBottom: '3px' }}>
          <div style={{ width: '14px' }} />
          {DAYS.map(day => (
            <div key={day} style={{ width: '14px', fontSize: '9px', color: '#64748b', textAlign: 'center' }}>{day}</div>
          ))}
        </div>

        <div className={styles.calendarGrid}>
          {calendarData.map((week, wi) => (
            <div key={wi} className={styles.calendarWeek}>
              {week.map((cell, di) => {
                const level = getLevel(cell.count)
                const dateStr = `${cell.date.getMonth() + 1}/${cell.date.getDate()}`
                return (
                  <div
                    key={di}
                    className={styles.calendarCell}
                    data-level={level}
                    title={`${dateStr}: ${cell.count}問`}
                  />
                )
              })}
            </div>
          ))}
        </div>

        {/* 凡例 */}
        <div className={styles.calendarLegend}>
          <span>少ない</span>
          {[0,1,2,3,4,5].map(l => (
            <div key={l} className={styles.legendCell} style={l > 0 ? {
              backgroundColor: ['#1d4ed8','#2563eb','#3b82f6','#60a5fa','#93c5fd'][l-1],
              borderColor: ['#1d4ed8','#2563eb','#3b82f6','#60a5fa','#93c5fd'][l-1]
            } : {}} />
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
