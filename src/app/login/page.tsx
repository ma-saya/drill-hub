'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import styles from './login.module.css'

export default function Login() {
  const router = useRouter()
  const [isSignUp, setIsSignUp] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

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
        // Supabaseの設定によってはメール確認が必要な場合がありますが、
        // 今回の簡略化のためそのままログインさせるかメッセージを出します
        alert('登録が完了しました！そのままログインできます。')
        setIsSignUp(false)
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        if (error) throw error
        router.push('/')
        router.refresh()
      }
    } catch (err: any) {
      setError(err.message || '認証エラーが発生しました。')
    } finally {
      setLoading(false)
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
      </div>
    </div>
  )
}
