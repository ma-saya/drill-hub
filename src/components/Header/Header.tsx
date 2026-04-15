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

  useEffect(() => {
    const checkUser = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      setUser(session?.user ?? null)
    }
    
    checkUser()

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const handleLogout = async () => {
    await supabase.auth.signOut()
    router.push('/login')
  }

  return (
    <header className={styles.header}>
      <Link href="/" className={styles.logo}>
        Java Drill Hub
      </Link>
      
      <nav className={styles.nav}>
        {user ? (
          <>
            <Link href="/problems" className={styles.navLink}>
              問題一覧
            </Link>
            <Link href="/mypage" className={styles.navLink}>
              マイページ
            </Link>
            <button onClick={handleLogout} className={styles.logoutBtn}>
              ログアウト
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
