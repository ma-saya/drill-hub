'use client'

import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import styles from './Header.module.css'
import { useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'

export default function Header() {
  const router = useRouter()
  const [user, setUser] = useState<User | null>(null)
  const [isGuest, setIsGuest] = useState(false)

  const checkStatus = async () => {
    // Supabaseセッション確認
    const { data: { session } } = await supabase.auth.getSession()
    setUser(session?.user ?? null)

    // ゲストモード確認
    const guestMode = localStorage.getItem('tech-drill-guest-mode') === 'true'
    setIsGuest(guestMode)
  }

  useEffect(() => {
    checkStatus()

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setUser(session?.user ?? null)
        // ログイン時はゲストモードをオフにする
        if (session) {
          localStorage.removeItem('tech-drill-guest-mode')
          setIsGuest(false)
        }
      }
    )

    // localStorageの変更を検知（別タブやLogin後のリダイレクト用）
    const handleStorageChange = () => {
      const guestMode = localStorage.getItem('tech-drill-guest-mode') === 'true'
      setIsGuest(guestMode)
    }
    window.addEventListener('storage', handleStorageChange)

    return () => {
      subscription.unsubscribe()
      window.removeEventListener('storage', handleStorageChange)
    }
  }, [])

  const handleLogout = async () => {
    await supabase.auth.signOut()
    localStorage.removeItem('tech-drill-guest-mode')
    setIsGuest(false)
    router.push('/login')
  }

  const isLoggedIn = !!user || isGuest

  return (
    <header className={styles.header}>
      <Link href="/" className={styles.logo}>
        Tech Drill Hub
      </Link>
      
      <nav className={styles.nav}>
        {isLoggedIn ? (
          <>
            <Link href="/problems" className={styles.navLink}>
              問題一覧
            </Link>
            <Link href="/mypage" className={styles.navLink}>
              マイページ
            </Link>
            <button onClick={handleLogout} className={styles.logoutBtn}>
              {user ? 'ログアウト' : '退出'}
            </button>
          </>
        ) : (
          <Link href="/login" className={styles.navLink}>
            ログイン
          </Link>
        )}
      </nav>
    </header>
  )
}
