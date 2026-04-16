'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { AuthError } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import styles from './login.module.css'

export default function Login() {
  const router = useRouter()
  const [isSignUp, setIsSignUp] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [passcode, setPasscode] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const GUEST_PASSCODE = 'Tech-Study'

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      if (isSignUp) {
        const { error } = await supabase.auth.signUp({
          email,
          password,
        })
        if (error) throw error
        alert('登録が完了しました！そのままログインできます。')
        setIsSignUp(false)
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        if (error) throw error
        
        // ログイン成功時はゲストモードを解除
        localStorage.removeItem('tech-drill-guest-mode')
        router.push('/')
        router.refresh()
      }
    } catch (err: unknown) {
      if (err instanceof AuthError) {
        setError(err.message)
      } else {
        setError('認証エラーが発生しました。')
      }
    } finally {
      setLoading(false)
    }
  }

  const handleGuestEntry = (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)

    if (passcode === GUEST_PASSCODE) {
      localStorage.setItem('tech-drill-guest-mode', 'true')
      router.push('/problems')
      router.refresh()
    } else {
      setError('合言葉が正しくありません。')
    }
  }

  return (
    <div className={styles.container}>
      <div className={`${styles.card} animate-fade-in`}>
        <h1 className={styles.title}>
          {isSignUp ? 'アカウント登録' : 'ログイン'}
        </h1>
        
        {error && <div className={styles.error}>{error}</div>}

        <form className={styles.form} onSubmit={handleAuth}>
          <div className={styles.inputGroup}>
            <label htmlFor="email" className={styles.label}>メールアドレス</label>
            <input
              id="email"
              type="email"
              placeholder="user@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className={styles.input}
              required
            />
          </div>
          
          <div className={styles.inputGroup}>
            <label htmlFor="password" className={styles.label}>パスワード</label>
            <input
              id="password"
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={styles.input}
              required
            />
          </div>

          <button type="submit" disabled={loading} className={styles.button}>
            {loading ? '処理中...' : (isSignUp ? '登録する' : 'ログイン')}
          </button>
        </form>

        <div className={styles.toggleContext}>
          {isSignUp ? '既にアカウントをお持ちですか？' : 'アカウントをお持ちでないですか？'}
          <button 
            type="button" 
            className={styles.toggleLink}
            onClick={() => {
              setIsSignUp(!isSignUp)
              setError(null)
            }}
          >
            {isSignUp ? 'ログイン' : '新規登録'}
          </button>
        </div>

        <div className={styles.divider}>
          <span>または</span>
        </div>

        <div className={styles.guestSection}>
          <h2 className={styles.guestTitle}>ゲストとして入室する</h2>
          <p className={styles.guestDesc}>お試し用の合言葉を入力してください</p>
          <form onSubmit={handleGuestEntry} className={styles.form}>
            <input
              type="text"
              placeholder="合言葉を入力"
              value={passcode}
              onChange={(e) => setPasscode(e.target.value)}
              className={styles.input}
              style={{ marginBottom: '1rem' }}
            />
            <button type="submit" className={styles.button} style={{ background: 'var(--secondary)', border: '1px solid var(--border)' }}>
              ゲスト入室
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
