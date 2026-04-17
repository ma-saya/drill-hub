import { supabase } from './supabase'

export const DEFAULT_DAILY_GOAL = 3
export const DAILY_GOAL_STORAGE_KEY = 'tech-drill-daily-goal-v1'

const MIN_DAILY_GOAL = 1
const MAX_DAILY_GOAL = 20

function normalizeDailyGoal(value: unknown) {
  const numericValue = typeof value === 'number' ? value : Number.parseInt(String(value), 10)

  if (!Number.isFinite(numericValue)) return DEFAULT_DAILY_GOAL

  return Math.min(MAX_DAILY_GOAL, Math.max(MIN_DAILY_GOAL, Math.round(numericValue)))
}

export function getCachedDailyGoal() {
  if (typeof window === 'undefined') return DEFAULT_DAILY_GOAL

  const cachedValue = window.localStorage.getItem(DAILY_GOAL_STORAGE_KEY)
  if (!cachedValue) return DEFAULT_DAILY_GOAL

  return normalizeDailyGoal(cachedValue)
}

export function cacheDailyGoal(goal: number) {
  if (typeof window === 'undefined') return

  window.localStorage.setItem(DAILY_GOAL_STORAGE_KEY, String(normalizeDailyGoal(goal)))
}

export async function loadDailyGoal(userId?: string | null) {
  const cachedGoal = getCachedDailyGoal()

  if (!userId) return cachedGoal

  try {
    const { data, error } = await supabase
      .from('user_settings')
      .select('daily_goal')
      .eq('user_id', userId)
      .maybeSingle()

    if (error) return cachedGoal

    if (typeof data?.daily_goal === 'number') {
      const normalizedGoal = normalizeDailyGoal(data.daily_goal)
      cacheDailyGoal(normalizedGoal)
      return normalizedGoal
    }
  } catch {
    return cachedGoal
  }

  return cachedGoal
}

export async function saveDailyGoal(userId: string | null | undefined, goal: number) {
  const normalizedGoal = normalizeDailyGoal(goal)
  cacheDailyGoal(normalizedGoal)

  if (!userId) {
    return { goal: normalizedGoal, savedRemotely: false }
  }

  try {
    const { error } = await supabase
      .from('user_settings')
      .upsert({
        user_id: userId,
        daily_goal: normalizedGoal,
        updated_at: new Date().toISOString(),
      }, {
        onConflict: 'user_id',
      })

    if (error) {
      return { goal: normalizedGoal, savedRemotely: false }
    }

    return { goal: normalizedGoal, savedRemotely: true }
  } catch {
    return { goal: normalizedGoal, savedRemotely: false }
  }
}
