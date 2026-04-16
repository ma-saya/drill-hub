import fs from 'fs'
import path from 'path'
import crypto from 'crypto'
import { execFileSync } from 'child_process'
import { fileURLToPath, pathToFileURL } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const repoRoot = path.resolve(__dirname, '..')
const tempDir = path.join(repoRoot, '.codex-temp', 'supabase-sync-tsc')
const outputFile = path.join(repoRoot, 'sql_step5_sync_all_technologies.sql')

const sourceFiles = [
  'src/lib/problemBank.ts',
  'src/lib/dockerProblemSeeds.ts',
  'src/lib/javascriptProblemSeeds.ts',
  'src/lib/linuxProblemSeeds.ts',
  'src/lib/reactProblemSeeds.ts',
  'src/lib/sqlProblemSeeds.ts',
  'src/lib/typescriptProblemSeeds.ts',
]

const localProblemExports = [
  'LOCAL_JAVA_PROBLEMS',
  'LOCAL_SPRING_BOOT_PROBLEMS',
  'LOCAL_AWS_PROBLEMS',
  'LOCAL_FLUTTER_PROBLEMS',
  'LOCAL_PHP_PROBLEMS',
  'LOCAL_HTML_CSS_PROBLEMS',
  'LOCAL_GIT_GITHUB_PROBLEMS',
  'LOCAL_SQL_PROBLEMS',
  'LOCAL_DOCKER_PROBLEMS',
  'LOCAL_JAVASCRIPT_PROBLEMS',
  'LOCAL_TYPESCRIPT_PROBLEMS',
  'LOCAL_REACT_PROBLEMS',
  'LOCAL_LINUX_PROBLEMS',
]

const technologyOrder = [
  'java',
  'spring-boot',
  'aws',
  'flutter',
  'php',
  'html-css',
  'git-github',
  'sql',
  'docker',
  'javascript',
  'typescript',
  'react',
  'linux',
]

const technologyDescriptions = {
  java: 'Java の学習問題',
  'spring-boot': 'Spring Boot の学習問題',
  aws: 'AWS の学習問題',
  flutter: 'Flutter の学習問題',
  php: 'PHP の学習問題',
  'html-css': 'HTML/CSS の学習問題',
  'git-github': 'Git/GitHub の学習問題',
  sql: 'SQL の学習問題',
  docker: 'Docker の学習問題',
  javascript: 'JavaScript の学習問題',
  typescript: 'TypeScript の学習問題',
  react: 'React の学習問題',
  linux: 'Linux の学習問題',
}

const fixedTechnologyIds = {
  java: '90000000-0000-0000-0000-000000000001',
  'spring-boot': '90000000-0000-0000-0000-000000000002',
}

function runTscCompile() {
  fs.rmSync(tempDir, { recursive: true, force: true })
  fs.mkdirSync(tempDir, { recursive: true })

  const tscCli = path.join(repoRoot, 'node_modules', 'typescript', 'bin', 'tsc')
  execFileSync(
    process.execPath,
    [
      tscCli,
      ...sourceFiles,
      '--module',
      'commonjs',
      '--target',
      'es2020',
      '--outDir',
      tempDir,
    ],
    {
      cwd: repoRoot,
      stdio: 'inherit',
    }
  )
}

function stableUuid(seed) {
  const hex = crypto.createHash('md5').update(seed).digest('hex')
  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    `4${hex.slice(13, 16)}`,
    `a${hex.slice(17, 20)}`,
    hex.slice(20, 32),
  ].join('-')
}

function sqlText(value) {
  if (value === null || value === undefined) return 'NULL'
  const text = String(value)

  if (!text.includes('$pb$')) {
    return `$pb$${text}$pb$`
  }

  return `'${text.replace(/'/g, "''")}'`
}

function indent(text, spaces) {
  const prefix = ' '.repeat(spaces)
  return text
    .split('\n')
    .map((line) => `${prefix}${line}`)
    .join('\n')
}

function chunk(items, size) {
  const result = []
  for (let index = 0; index < items.length; index += size) {
    result.push(items.slice(index, index + size))
  }
  return result
}

function problemTheme(problem) {
  return Array.isArray(problem.themes) ? problem.themes[0] : problem.themes
}

function technologyOf(problem) {
  const theme = problemTheme(problem)
  const technologies = theme?.technologies
  return Array.isArray(technologies) ? technologies[0] : technologies
}

function buildTechnologyId(slug) {
  return fixedTechnologyIds[slug] ?? stableUuid(`technology:${slug}`)
}

function buildThemeId(themeKey) {
  return stableUuid(`theme:${themeKey}`)
}

function buildProblemId(problemKey) {
  return stableUuid(`problem:${problemKey}`)
}

function buildInsertStatement(tableName, columns, rows, onConflictClause) {
  const valueLines = rows.map((row) => `(${row.join(', ')})`)
  return [
    `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES`,
    `${indent(valueLines.join(',\n'), 2)}`,
    onConflictClause,
    ';',
  ].join('\n')
}

runTscCompile()

const compiledProblemBankPath = path.join(tempDir, 'problemBank.js')
const problemBank = await import(pathToFileURL(compiledProblemBankPath).href)

const localProblems = localProblemExports.flatMap((exportName) => problemBank[exportName] ?? [])

const technologies = new Map()
const themes = new Map()

for (const problem of localProblems) {
  const technology = technologyOf(problem)
  const theme = problemTheme(problem)

  if (!technology || !theme) continue

  if (!technologies.has(technology.slug)) {
    technologies.set(technology.slug, {
      id: buildTechnologyId(technology.slug),
      slug: technology.slug,
      name: technology.name,
    })
  }

  if (!themes.has(problem.theme_id)) {
    themes.set(problem.theme_id, {
      id: buildThemeId(problem.theme_id),
      sourceThemeId: problem.theme_id,
      name: theme.name,
      technologySlug: technology.slug,
    })
  }
}

const orderedTechnologies = technologyOrder
  .filter((slug) => technologies.has(slug))
  .map((slug, index) => ({
    ...technologies.get(slug),
    displayOrder: index + 1,
    description: technologyDescriptions[slug] ?? `${technologies.get(slug).name} の学習問題`,
  }))

const orderedThemes = Array.from(themes.values())
  .sort((left, right) => {
    const leftTech = technologyOrder.indexOf(left.technologySlug)
    const rightTech = technologyOrder.indexOf(right.technologySlug)
    if (leftTech !== rightTech) return leftTech - rightTech

    const leftProblem = localProblems.find((problem) => problem.theme_id === left.sourceThemeId)
    const rightProblem = localProblems.find((problem) => problem.theme_id === right.sourceThemeId)

    return (leftProblem?.display_order ?? 0) - (rightProblem?.display_order ?? 0)
  })
  .map((theme, index) => ({
    ...theme,
    technologyId: buildTechnologyId(theme.technologySlug),
    displayOrder: index + 6,
  }))

const themeIdMap = new Map(orderedThemes.map((theme) => [theme.sourceThemeId, theme.id]))

const orderedProblems = [...localProblems]
  .sort((left, right) => left.display_order - right.display_order)
  .map((problem) => ({
    id: buildProblemId(problem.id),
    themeId: themeIdMap.get(problem.theme_id),
    title: problem.title,
    level: problem.level,
    type: problem.type,
    statement: problem.statement,
    requirements: problem.requirements,
    hint: problem.hint,
    answer: problem.answer,
    explanation: problem.explanation,
    commonMistakes: problem.common_mistakes,
    displayOrder: problem.display_order,
  }))

const technologySummaryLines = orderedTechnologies.map((technology) => {
  const count = orderedProblems.filter((problem) => {
    const theme = orderedThemes.find((item) => item.id === problem.themeId)
    return theme?.technologySlug === technology.slug
  }).length
  return `--   ${technology.name}: ${count}問`
})

const technologyRows = orderedTechnologies.map((technology) => [
  sqlText(technology.id),
  sqlText(technology.name),
  sqlText(technology.slug),
  sqlText(technology.description),
  String(technology.displayOrder),
  'TRUE',
])

const themeRows = orderedThemes.map((theme) => [
  sqlText(theme.id),
  sqlText(theme.technologyId),
  sqlText(theme.name),
  'NULL',
  String(theme.displayOrder),
])

const problemRows = orderedProblems.map((problem) => [
  sqlText(problem.id),
  sqlText(problem.themeId),
  sqlText(problem.title),
  String(problem.level),
  sqlText(problem.type),
  sqlText(problem.statement),
  sqlText(problem.requirements),
  sqlText(problem.hint),
  sqlText(problem.answer),
  sqlText(problem.explanation),
  sqlText(problem.commonMistakes),
  String(problem.displayOrder),
  'TRUE',
])

const problemStatements = chunk(problemRows, 100).map((rows) =>
  buildInsertStatement(
    'problems',
    [
      'id',
      'theme_id',
      'title',
      'level',
      'type',
      'statement',
      'requirements',
      'hint',
      'answer',
      'explanation',
      'common_mistakes',
      'display_order',
      'is_active',
    ],
    rows,
    `ON CONFLICT (id) DO UPDATE SET
  theme_id = EXCLUDED.theme_id,
  title = EXCLUDED.title,
  level = EXCLUDED.level,
  type = EXCLUDED.type,
  statement = EXCLUDED.statement,
  requirements = EXCLUDED.requirements,
  hint = EXCLUDED.hint,
  answer = EXCLUDED.answer,
  explanation = EXCLUDED.explanation,
  common_mistakes = EXCLUDED.common_mistakes,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())`
  )
)

const sql = [
  '-- =============================================',
  '-- STEP 5: 追加技術とローカル問題を Supabase に同期する',
  '-- このSQLは既存の Java 問題を残したまま、追加技術と追加問題を DB 化します。',
  '-- 既存の study_records は削除しません。',
  '-- =============================================',
  '-- 追加対象の件数',
  `--   合計: ${orderedProblems.length}問`,
  ...technologySummaryLines,
  '',
  'BEGIN;',
  '',
  'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";',
  '',
  'CREATE TABLE IF NOT EXISTS technologies (',
  '  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),',
  '  name TEXT NOT NULL,',
  '  slug TEXT NOT NULL UNIQUE,',
  '  description TEXT,',
  '  display_order INTEGER NOT NULL DEFAULT 0,',
  '  is_active BOOLEAN NOT NULL DEFAULT true,',
  "  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,",
  "  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL",
  ');',
  '',
  'ALTER TABLE technologies ENABLE ROW LEVEL SECURITY;',
  'ALTER TABLE themes ENABLE ROW LEVEL SECURITY;',
  'ALTER TABLE problems ENABLE ROW LEVEL SECURITY;',
  'ALTER TABLE study_records ENABLE ROW LEVEL SECURITY;',
  '',
  'DO $$',
  'BEGIN',
  '  IF NOT EXISTS (',
  "    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'technologies' AND policyname = 'Allow public read access on technologies'",
  '  ) THEN',
  '    CREATE POLICY "Allow public read access on technologies"',
  '      ON technologies',
  '      FOR SELECT',
  '      USING (true);',
  '  END IF;',
  '',
  '  IF NOT EXISTS (',
  "    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'themes' AND policyname = 'Allow public read access on themes'",
  '  ) THEN',
  '    CREATE POLICY "Allow public read access on themes"',
  '      ON themes',
  '      FOR SELECT',
  '      USING (true);',
  '  END IF;',
  '',
  '  IF NOT EXISTS (',
  "    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'problems' AND policyname = 'Allow public read access on problems'",
  '  ) THEN',
  '    CREATE POLICY "Allow public read access on problems"',
  '      ON problems',
  '      FOR SELECT',
  '      USING (true);',
  '  END IF;',
  '',
  '  IF NOT EXISTS (',
  "    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'study_records' AND policyname = 'Users can create their own study records'",
  '  ) THEN',
  '    CREATE POLICY "Users can create their own study records"',
  '      ON study_records',
  '      FOR INSERT',
  '      WITH CHECK (auth.uid() = user_id);',
  '  END IF;',
  '',
  '  IF NOT EXISTS (',
  "    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'study_records' AND policyname = 'Users can update their own study records'",
  '  ) THEN',
  '    CREATE POLICY "Users can update their own study records"',
  '      ON study_records',
  '      FOR UPDATE',
  '      USING (auth.uid() = user_id);',
  '  END IF;',
  '',
  '  IF NOT EXISTS (',
  "    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'study_records' AND policyname = 'Users can view their own study records'",
  '  ) THEN',
  '    CREATE POLICY "Users can view their own study records"',
  '      ON study_records',
  '      FOR SELECT',
  '      USING (auth.uid() = user_id);',
  '  END IF;',
  'END $$;',
  '',
  'ALTER TABLE themes',
  '  ADD COLUMN IF NOT EXISTS technology_id UUID;',
  '',
  'DO $$',
  'BEGIN',
  '  IF NOT EXISTS (',
  "    SELECT 1 FROM pg_constraint WHERE conname = 'themes_technology_id_fkey'",
  '  ) THEN',
  '    ALTER TABLE themes',
  '      ADD CONSTRAINT themes_technology_id_fkey',
  '      FOREIGN KEY (technology_id) REFERENCES technologies(id) ON DELETE RESTRICT;',
  '  END IF;',
  'END $$;',
  '',
  'CREATE INDEX IF NOT EXISTS idx_themes_technology_id ON themes(technology_id);',
  '',
  'DO $$',
  'DECLARE',
  '  current_definition TEXT;',
  'BEGIN',
  "  SELECT pg_get_constraintdef(oid) INTO current_definition FROM pg_constraint WHERE conname = 'problems_type_check' AND conrelid = 'problems'::regclass;",
  '',
  "  IF current_definition IS NULL OR current_definition NOT LIKE '%code%' OR current_definition NOT LIKE '%procedure%' OR current_definition NOT LIKE '%concept%' THEN",
  '    IF current_definition IS NOT NULL THEN',
  '      ALTER TABLE problems DROP CONSTRAINT problems_type_check;',
  '    END IF;',
  '',
  '    ALTER TABLE problems',
  "      ADD CONSTRAINT problems_type_check CHECK (type IN ('normal', 'fill_blank', 'code', 'procedure', 'concept'));",
  '  END IF;',
  'END $$;',
  '',
  buildInsertStatement(
    'technologies',
    ['id', 'name', 'slug', 'description', 'display_order', 'is_active'],
    technologyRows,
    `ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  slug = EXCLUDED.slug,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())`
  ),
  '',
  `UPDATE themes
SET technology_id = ${sqlText(fixedTechnologyIds.java)}
WHERE technology_id IS NULL;`,
  '',
  buildInsertStatement(
    'themes',
    ['id', 'technology_id', 'name', 'description', 'display_order'],
    themeRows,
    `ON CONFLICT (id) DO UPDATE SET
  technology_id = EXCLUDED.technology_id,
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order`
  ),
  '',
  ...problemStatements,
  '',
  'COMMIT;',
  '',
].join('\n')

fs.writeFileSync(outputFile, sql, 'utf8')

console.log(`Generated ${path.relative(repoRoot, outputFile)}`)
console.log(`Problems: ${orderedProblems.length}`)
