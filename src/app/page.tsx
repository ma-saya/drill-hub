'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { supabase } from '@/lib/supabase'
import styles from './page.module.css'

const DAILY_GOAL = 3 // 1日の目標問題数

export default function Home() {
  const [session, setSession] = useState<any>(null)
  const [stats, setStats] = useState({
    totalSolved: 0,
    weakCount: 0,
    themeCount: 5,
  })
  const [streak, setStreak] = useState(0)
  const [todayCount, setTodayCount] = useState(0)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      if (session) {
        fetchStats(session.user.id)
      }
    })
  }, [])

  const fetchStats = async (userId: string) => {
    const { data: records, error } = await supabase
      .from('study_records')
      .select('self_assessment, is_weak, last_studied_at')
      .eq('user_id', userId)

    if (error) {
      console.error(error)
      return
    }

    if (records) {
      const solved = records.filter(r => r.self_assessment === 'success').length
      const weak = records.filter(r => r.is_weak).length
      setStats(prev => ({ ...prev, totalSolved: solved, weakCount: weak }))

      // 今日の学習数
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const todayStudied = records.filter(r => {
        const d = new Date(r.last_studied_at)
        d.setHours(0, 0, 0, 0)
        return d.getTime() === today.getTime()
      }).length
      setTodayCount(todayStudied)

      // 連続学習日数（ストリーク）を計算
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
      setStreak(streakCount)
    }
  }

  const todayProgress = Math.min((todayCount / DAILY_GOAL) * 100, 100)
  const goalAchieved = todayCount >= DAILY_GOAL

  return (
    <div className={styles.container}>
      <div className={`${styles.hero} animate-fade-in`}>
        <h1 className={styles.title}>Javaの実装力を、書くことで鍛える。</h1>
        <p className={styles.subtitle}>
          コードを読み、実際に書き、模範解答と比較する。<br/>
          研修卒業レベルの「自分で作る力」を身につけるための特化型学習アプリです。
        </p>
      </div>

      {session ? (
        <div className="animate-fade-in" style={{ animationDelay: '0.2s' }}>

          {/* 習慣ウィジェット */}
          <div className={styles.habitRow}>
            {/* ストリーク */}
            <div className={styles.habitCard}>
              <div className={styles.habitIcon}>🔥</div>
              <div className={styles.habitValue}>{streak}</div>
              <div className={styles.habitLabel}>日連続学習中</div>
              {streak === 0 && (
                <div className={styles.habitSub}>今日問題を解いてストリークを始めよう！</div>
              )}
            </div>

            {/* 今日のノルマ */}
            <div className={styles.habitCard}>
              <div className={styles.habitIcon}>{goalAchieved ? '🎯' : '📝'}</div>
              <div className={styles.habitValue}>
                {todayCount} <span className={styles.habitValueSmall}>/ {DAILY_GOAL}</span>
              </div>
              <div className={styles.habitLabel}>今日の目標問題数</div>
              <div className={styles.progressBar}>
                <div
                  className={styles.progressFill}
                  style={{
                    width: `${todayProgress}%`,
                    backgroundColor: goalAchieved ? 'var(--accent)' : 'var(--primary)'
                  }}
                />
              </div>
              {goalAchieved
                ? <div className={styles.habitSub} style={{ color: 'var(--accent)' }}>今日のノルマ達成！🎉</div>
                : <div className={styles.habitSub}>あと{DAILY_GOAL - todayCount}問で目標達成！</div>
              }
            </div>
          </div>

          <div className={styles.statsGrid}>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.totalSolved}</div>
              <div className={styles.statLabel}>クリア済み問題</div>
            </div>
            <div className={styles.statCard}>
              <div className={styles.statValue} style={{ color: 'var(--warning)' }}>{stats.weakCount}</div>
              <div className={styles.statLabel}>苦手な問題</div>
            </div>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.themeCount}</div>
              <div className={styles.statLabel}>学習テーマ</div>
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
        <div className={styles.actions + ' animate-fade-in'} style={{ animationDelay: '0.2s' }}>
          <Link href="/login" className={styles.primaryAction}>
            ログインして始める
          </Link>
        </div>
      )}
    </div>
  )
}

