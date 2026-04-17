'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { type Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import { DEFAULT_DAILY_GOAL, loadDailyGoal } from '@/lib/userSettings'
import styles from './page.module.css'

export default function Home() {
  const [session, setSession] = useState<Session | null>(null)
  const [stats, setStats] = useState({
    totalSolved: 0,
    weakCount: 0,
    technologyCount: 1,
  })
  const [streak, setStreak] = useState(0)
  const [todayCount, setTodayCount] = useState(0)
  const [dailyGoal, setDailyGoal] = useState(DEFAULT_DAILY_GOAL)

  async function fetchStats(userId: string) {
    const [recordsResult, technologiesResult] = await Promise.all([
      supabase
        .from('study_records')
        .select('self_assessment, is_weak, last_studied_at')
        .eq('user_id', userId),
      supabase
        .from('technologies')
        .select('id')
        .eq('is_active', true),
    ])

    if (recordsResult.error) {
      console.error(recordsResult.error)
      return
    }

    if (!technologiesResult.error && technologiesResult.data) {
      setStats((prev) => ({
        ...prev,
        technologyCount: technologiesResult.data.length || 1,
      }))
    }

    if (recordsResult.data) {
      const records = recordsResult.data
      const solved = records.filter((record) => record.self_assessment === 'success').length
      const weak = records.filter((record) => record.is_weak).length
      setStats((prev) => ({ ...prev, totalSolved: solved, weakCount: weak }))

      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const todayStudied = records.filter((record) => {
        const studiedAt = new Date(record.last_studied_at)
        studiedAt.setHours(0, 0, 0, 0)
        return studiedAt.getTime() === today.getTime()
      }).length
      setTodayCount(todayStudied)

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

      setStreak(streakCount)
    }
  }

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session: currentSession } }) => {
      setSession(currentSession)
      if (!currentSession) return

      void loadDailyGoal(currentSession.user.id).then(setDailyGoal)
      void fetchStats(currentSession.user.id)
    })
  }, [])

  const todayProgress = Math.min((todayCount / dailyGoal) * 100, 100)
  const goalAchieved = todayCount >= dailyGoal

  return (
    <div className={styles.container}>
      <div className={`${styles.hero} animate-fade-in`}>
        <h1 className={styles.title}>技術の基礎を、無理なく積み上げる。</h1>
        <p className={styles.subtitle}>
          コードや設計の基本を読み、実際に書き、評価しながら学べる学習アプリです。
          <br />
          Java を起点に、Spring Boot などの周辺技術へも段階的に広げられます。
        </p>
      </div>

      {session ? (
        <div className="animate-fade-in" style={{ animationDelay: '0.2s' }}>
          <div className={styles.habitRow}>
            <div className={styles.habitCard}>
              <div className={styles.habitIcon}>🔥</div>
              <div className={styles.habitValue}>{streak}</div>
              <div className={styles.habitLabel}>連続学習日数</div>
              {streak === 0 && (
                <div className={styles.habitSub}>今日の学習を始めてストリークを作りましょう。</div>
              )}
            </div>

            <div className={styles.habitCard}>
              <div className={styles.habitIcon}>{goalAchieved ? '🎯' : '📝'}</div>
              <div className={styles.habitValue}>
                {todayCount} <span className={styles.habitValueSmall}>/ {dailyGoal}</span>
              </div>
              <div className={styles.habitLabel}>今日の目標問題数</div>
              <div className={styles.progressBar}>
                <div
                  className={styles.progressFill}
                  style={{
                    width: `${todayProgress}%`,
                    backgroundColor: goalAchieved ? 'var(--accent)' : 'var(--primary)',
                  }}
                />
              </div>
              {goalAchieved ? (
                <div className={styles.habitSub} style={{ color: 'var(--accent)' }}>
                  今日の目標を達成しました。
                </div>
              ) : (
                <div className={styles.habitSub}>あと{dailyGoal - todayCount}問で目標達成です。</div>
              )}
            </div>
          </div>

          <div className={styles.statsGrid}>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.totalSolved}</div>
              <div className={styles.statLabel}>クリア済み問題</div>
            </div>
            <div className={styles.statCard}>
              <div className={styles.statValue} style={{ color: 'var(--warning)' }}>
                {stats.weakCount}
              </div>
              <div className={styles.statLabel}>苦手な問題</div>
            </div>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.technologyCount}</div>
              <div className={styles.statLabel}>学習中の技術</div>
            </div>
          </div>

          <div className={styles.actions}>
            <Link href="/problems" className={styles.primaryAction}>
              問題一覧へ進む
            </Link>
            <Link href="/mypage" className={styles.secondaryAction}>
              学習カレンダーを見る
            </Link>
          </div>
        </div>
      ) : (
        <div className={`${styles.actions} animate-fade-in`} style={{ animationDelay: '0.2s' }}>
          <Link href="/login" className={styles.primaryAction}>
            ログインして始める
          </Link>
        </div>
      )}
    </div>
  )
}
