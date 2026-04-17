import { DOCKER_PROBLEM_SEEDS } from './dockerProblemSeeds'
import { JAVASCRIPT_PROBLEM_SEEDS } from './javascriptProblemSeeds'
import { LINUX_PROBLEM_SEEDS } from './linuxProblemSeeds'
import { REACT_PROBLEM_SEEDS } from './reactProblemSeeds'
import { SQL_PROBLEM_SEEDS } from './sqlProblemSeeds'
import { TYPESCRIPT_PROBLEM_SEEDS } from './typescriptProblemSeeds'

export type TechnologyInfo = {
  name: string
  slug: string
}

export type ThemeInfo = {
  name: string
  technology_id?: string | null
  technologies?: TechnologyInfo | TechnologyInfo[] | null
}

export type ThemeRelation = ThemeInfo | ThemeInfo[] | null | undefined

export type ProblemRecord = {
  id: string
  theme_id: string
  title: string
  level: number
  type: string
  statement: string
  requirements: string | null
  hint: string | null
  answer: string
  explanation: string | null
  common_mistakes: string | null
  display_order: number
  themes?: ThemeRelation
}

export type StudyRecordSummary = {
  problem_id: string
  self_assessment: string
  is_weak: boolean
}

type LocalStudyRecord = {
  problem_id: string
  user_code: string
  self_assessment: string | null
  is_weak: boolean
  last_studied_at: string
}

const LOCAL_RECORDS_KEY = 'tech-drill-local-records-v1'

const SPRING_BOOT_TECHNOLOGY: TechnologyInfo = {
  name: 'Spring Boot',
  slug: 'spring-boot',
}

const AWS_TECHNOLOGY: TechnologyInfo = {
  name: 'AWS',
  slug: 'aws',
}

const FLUTTER_TECHNOLOGY: TechnologyInfo = {
  name: 'Flutter',
  slug: 'flutter',
}

const PHP_TECHNOLOGY: TechnologyInfo = {
  name: 'PHP',
  slug: 'php',
}

const HTML_CSS_TECHNOLOGY: TechnologyInfo = {
  name: 'HTML/CSS',
  slug: 'html-css',
}

const GIT_GITHUB_TECHNOLOGY: TechnologyInfo = {
  name: 'Git/GitHub',
  slug: 'git-github',
}

const SQL_TECHNOLOGY: TechnologyInfo = {
  name: 'SQL',
  slug: 'sql',
}

const DOCKER_TECHNOLOGY: TechnologyInfo = {
  name: 'Docker',
  slug: 'docker',
}

const JAVASCRIPT_TECHNOLOGY: TechnologyInfo = {
  name: 'JavaScript',
  slug: 'javascript',
}

const TYPESCRIPT_TECHNOLOGY: TechnologyInfo = {
  name: 'TypeScript',
  slug: 'typescript',
}

const REACT_TECHNOLOGY: TechnologyInfo = {
  name: 'React',
  slug: 'react',
}

const LINUX_TECHNOLOGY: TechnologyInfo = {
  name: 'Linux',
  slug: 'linux',
}

const createSpringBootTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-spring-boot',
  technologies: SPRING_BOOT_TECHNOLOGY,
})

const createAwsTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-aws',
  technologies: AWS_TECHNOLOGY,
})

const createFlutterTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-flutter',
  technologies: FLUTTER_TECHNOLOGY,
})

const createPhpTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-php',
  technologies: PHP_TECHNOLOGY,
})

const createHtmlCssTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-html-css',
  technologies: HTML_CSS_TECHNOLOGY,
})

const createGitGithubTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-git-github',
  technologies: GIT_GITHUB_TECHNOLOGY,
})

const createSqlTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-sql',
  technologies: SQL_TECHNOLOGY,
})

const createDockerTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-docker',
  technologies: DOCKER_TECHNOLOGY,
})

const createJavaScriptTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-javascript',
  technologies: JAVASCRIPT_TECHNOLOGY,
})

const createTypeScriptTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-typescript',
  technologies: TYPESCRIPT_TECHNOLOGY,
})

const createReactTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-react',
  technologies: REACT_TECHNOLOGY,
})

const createLinuxTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-linux',
  technologies: LINUX_TECHNOLOGY,
})

export const LEGACY_JAVA_TECHNOLOGY: TechnologyInfo = {
  name: 'Java',
  slug: 'java',
}

const createJavaTheme = (name: string): ThemeInfo => ({
  name,
  technology_id: 'local-java',
  technologies: LEGACY_JAVA_TECHNOLOGY,
})

type GeneratedProblemInput = Omit<ProblemRecord, 'display_order' | 'themes'> & {
  themeName: string
}

const withLocalMetadata = (
  problems: GeneratedProblemInput[],
  startOrder: number,
  themeFactory: (name: string) => ThemeInfo
): ProblemRecord[] =>
  problems.map(({ themeName, ...problem }, index) => ({
    ...problem,
    display_order: startOrder + index,
    themes: themeFactory(themeName),
  }))

const fillBlankProblem = (problem: {
  id: string
  theme_id: string
  themeName: string
  title: string
  level: number
  statement: string
  answer: string
  hint: string
  explanation: string
  common_mistakes: string
  requirements?: string
}): GeneratedProblemInput => ({
  ...problem,
  type: 'fill_blank',
  requirements: problem.requirements ?? '空欄だけを書いてください。',
})

const writtenProblem = (problem: {
  id: string
  theme_id: string
  themeName: string
  title: string
  level: number
  type?: string
  statement: string
  answer: string
  hint: string
  explanation: string
  common_mistakes: string
  requirements: string
}): GeneratedProblemInput => ({
  ...problem,
  type: problem.type ?? 'code',
})

const generatedProblem = (problem: {
  id: string
  theme_id: string
  themeName: string
  title: string
  level: number
  type: string
  statement: string
  answer: string
  hint: string
  explanation: string
  common_mistakes: string
  requirements?: string
}): GeneratedProblemInput =>
  problem.type === 'fill_blank'
    ? fillBlankProblem(problem)
    : writtenProblem({
        ...problem,
        requirements: problem.requirements ?? '回答をそのまま書いてください。',
      })

export const LOCAL_JAVA_PROBLEMS: ProblemRecord[] = [
  {
    id: 'local-java-001',
    theme_id: 'local-java-bugfix',
    title: 'セミコロン不足でコンパイルエラーになるコードを直す',
    level: 1,
    type: 'normal',
    statement:
      '次の Java コードはコンパイルエラーになります。原因を直したコードを書いてください。\n\npublic class Main {\n    public static void main(String[] args) {\n        int count = 3\n        System.out.println(count);\n    }\n}',
    requirements:
      '`int count = 3;` に直すこと\nそれ以外は大きく変えなくてよいこと',
    hint: 'Java は文の終わりに記号が必要です。',
    answer:
      'public class Main {\n    public static void main(String[] args) {\n        int count = 3;\n        System.out.println(count);\n    }\n}',
    explanation:
      'Java のコンパイルエラーで最も基本的なのが、文末のセミコロン不足です。',
    common_mistakes:
      '変数型や `println` を変える必要はなく、今回の原因は文末記号だけです。',
    display_order: 806,
    themes: createJavaTheme('Java: バグ修正'),
  },
  {
    id: 'local-java-002',
    theme_id: 'local-java-bugfix',
    title: '文字列比較で==を使っているバグを直す',
    level: 2,
    type: 'normal',
    statement:
      '次のコードは、入力が `"admin"` でも期待どおりに判定されないことがあります。正しく判定できるように直してください。\n\nString role = \"admin\";\nif (role == \"admin\") {\n    System.out.println(\"管理者です\");\n}',
    requirements:
      '`equals` を使うこと\n条件式だけでなく、コード全体を書いてよいこと',
    hint: 'Java の文字列比較は、参照比較ではなく内容比較を使います。',
    answer:
      'String role = "admin";\nif ("admin".equals(role)) {\n    System.out.println("管理者です");\n}',
    explanation:
      'Java の `==` は参照比較なので、文字列の内容を比べたいときは `equals` を使います。',
    common_mistakes:
      '`role.equals("admin")` でも多くの場合動きますが、null 安全まで考えるなら定数側から呼ぶ形が安定です。',
    display_order: 807,
    themes: createJavaTheme('Java: バグ修正'),
  },
  {
    id: 'local-java-003',
    theme_id: 'local-java-bugfix',
    title: '配列ループの境界ミスを直す',
    level: 2,
    type: 'normal',
    statement:
      '次のコードは `ArrayIndexOutOfBoundsException` になる可能性があります。正しく最後まで表示できるように直してください。\n\nint[] scores = {70, 80, 90};\nfor (int i = 0; i <= scores.length; i++) {\n    System.out.println(scores[i]);\n}',
    requirements:
      'for 文の条件を修正すること\n配列の中身はそのままでよいこと',
    hint: '配列の添字は 0 から始まり、最後は `length - 1` です。',
    answer:
      'int[] scores = {70, 80, 90};\nfor (int i = 0; i < scores.length; i++) {\n    System.out.println(scores[i]);\n}',
    explanation:
      '配列ループでは `<=` を使うと最後に1つはみ出しやすく、研修でもよく出る定番ミスです。',
    common_mistakes:
      '`scores.length - 1` を条件式へ直接書く方法もありますが、`i < scores.length` の方が読みやすいです。',
    display_order: 808,
    themes: createJavaTheme('Java: バグ修正'),
  },
  {
    id: 'local-java-004',
    theme_id: 'local-java-bugfix',
    title: 'ScannerのnextInt後にnextLineが空になるバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次のコードでは、年齢入力のあとに名前が正しく読めないことがあります。原因を直したコードを書いてください。\n\nScanner scanner = new Scanner(System.in);\nSystem.out.print(\"年齢: \");\nint age = scanner.nextInt();\nSystem.out.print(\"名前: \");\nString name = scanner.nextLine();\nSystem.out.println(name + \" さん\");',
    requirements:
      '`nextInt()` のあとに改行を読み飛ばす処理を入れること\n`name` は `nextLine()` で取得すること',
    hint: '`nextInt()` のあとには入力バッファに改行が残ることがあります。',
    answer:
      'Scanner scanner = new Scanner(System.in);\nSystem.out.print("年齢: ");\nint age = scanner.nextInt();\nscanner.nextLine();\nSystem.out.print("名前: ");\nString name = scanner.nextLine();\nSystem.out.println(name + " さん");',
    explanation:
      '`nextInt()` のあとに残った改行を `nextLine()` が先に読んでしまうのは、Java 初学者の定番バグです。',
    common_mistakes:
      '`name = scanner.next()` に変えると空白を含む名前を扱いにくくなり、根本修正としては弱くなります。',
    display_order: 809,
    themes: createJavaTheme('Java: バグ修正'),
  },
  {
    id: 'local-java-005',
    theme_id: 'local-java-bugfix',
    title: 'ArrayList未初期化によるNullPointerExceptionを直す',
    level: 3,
    type: 'normal',
    statement:
      '次のコードは実行時に `NullPointerException` になります。正しくタスク追加できるように直してください。\n\nimport java.util.ArrayList;\nimport java.util.List;\n\npublic class Main {\n    public static void main(String[] args) {\n        List<String> tasks = null;\n        tasks.add(\"買い物\");\n        System.out.println(tasks);\n    }\n}',
    requirements:
      '`tasks` を `new ArrayList<>()` で初期化すること\n追加処理はそのまま活かすこと',
    hint: '`null` のままメソッドを呼ぶと例外になります。',
    answer:
      'import java.util.ArrayList;\nimport java.util.List;\n\npublic class Main {\n    public static void main(String[] args) {\n        List<String> tasks = new ArrayList<>();\n        tasks.add("買い物");\n        System.out.println(tasks);\n    }\n}',
    explanation:
      'コレクションは宣言だけでは使えず、実体を生成してから使う必要があります。',
    common_mistakes:
      '`List<String> tasks;` とだけ書いても未初期化のままなので、修正としては不十分です。',
    display_order: 810,
    themes: createJavaTheme('Java: バグ修正'),
  },
]

export const LOCAL_SPRING_BOOT_PROBLEMS: ProblemRecord[] = [
  {
    id: 'local-spring-boot-001',
    theme_id: 'local-spring-controller',
    title: 'RESTコントローラーの基本アノテーション',
    level: 1,
    type: 'fill_blank',
    statement:
      '以下のクラスを REST API のコントローラーとして扱いたいです。\n空欄に入るアノテーションだけを答えてください。\n\n__________\npublic class TaskController {\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'HTML画面ではなくJSONを返すコントローラーで使うアノテーションです。',
    answer: '@RestController',
    explanation:
      '@RestController は @Controller と @ResponseBody の役割をまとめて持つため、REST API の入口でよく使います。',
    common_mistakes:
      '@Controller と書くと、戻り値をテンプレート名として扱う構成になりやすい点に注意です。',
    display_order: 601,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-002',
    theme_id: 'local-spring-controller',
    title: 'GETエンドポイントのマッピング',
    level: 1,
    type: 'fill_blank',
    statement:
      '一覧取得用の GET エンドポイントを作りたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@RestController\n@RequestMapping("/tasks")\npublic class TaskController {\n\n    __________\n    public List<String> getTasks() {\n        return List.of("A", "B");\n    }\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'GETメソッド用のマッピングです。',
    answer: '@GetMapping',
    explanation:
      '@GetMapping を付けると、このメソッドが GET リクエストを受け取る入口になります。',
    common_mistakes:
      '@RequestMapping だけでも書けますが、初学者は GET / POST を明確に分ける書き方の方が理解しやすいです。',
    display_order: 602,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-003',
    theme_id: 'local-spring-controller',
    title: 'PathVariableでIDを受け取る',
    level: 1,
    type: 'fill_blank',
    statement:
      'URL に含まれる id を受け取りたいです。\n空欄に入る引数だけを答えてください。\n\n@GetMapping("/{id}")\npublic String getTask(__________) {\n    return "task";\n}',
    requirements: '空欄には引数1つ分だけを書いてください。',
    hint: 'URLの {id} をメソッド引数へ結びつけるアノテーションです。',
    answer: '@PathVariable Long id',
    explanation:
      '@PathVariable を付けると、URLパス中の値をそのまま引数で受け取れます。',
    common_mistakes:
      'RequestParam と混同しやすいですが、今回はクエリ文字列ではなくパスの一部です。',
    display_order: 603,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-004',
    theme_id: 'local-spring-controller',
    title: 'RequestParamで検索条件を受け取る',
    level: 2,
    type: 'fill_blank',
    statement:
      'クエリパラメータの status を受け取りたいです。\n空欄に入る引数だけを答えてください。\n\n@GetMapping("/search")\npublic String search(__________) {\n    return status;\n}',
    requirements: '空欄には引数1つ分だけを書いてください。',
    hint: 'URLの ?status=done のような値を受け取るときに使います。',
    answer: '@RequestParam String status',
    explanation:
      '@RequestParam はクエリパラメータを受け取るための基本アノテーションです。',
    common_mistakes:
      '@PathVariable と混同すると、URL設計と受け取り方がずれてしまいます。',
    display_order: 604,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-005',
    theme_id: 'local-spring-request-response',
    title: 'RequestBodyでJSONを受け取る',
    level: 2,
    type: 'fill_blank',
    statement:
      'POSTされた JSON を CreateTaskRequest に受け取りたいです。\n空欄に入る引数だけを答えてください。\n\n@PostMapping\npublic String createTask(__________) {\n    return request.getTitle();\n}',
    requirements: '空欄には引数1つ分だけを書いてください。',
    hint: 'JSONボディをJavaオブジェクトへ変換して受け取りたい場面です。',
    answer: '@RequestBody CreateTaskRequest request',
    explanation:
      '@RequestBody を付けると、リクエストボディのJSONを指定したクラスへ変換して受け取れます。',
    common_mistakes:
      'RequestParam を使うと、JSONボディではなくクエリパラメータとして扱われます。',
    display_order: 701,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-006',
    theme_id: 'local-spring-request-response',
    title: '201 Createdでレスポンスを返す',
    level: 3,
    type: 'fill_blank',
    statement:
      '作成成功時に 201 Created を返したいです。\n空欄に入る return の右辺だけを答えてください。\n\n@PostMapping\npublic ResponseEntity<TaskResponse> create(@RequestBody CreateTaskRequest request) {\n    TaskResponse response = service.create(request);\n    return __________;\n}',
    requirements: '空欄には return の右辺だけを書いてください。',
    hint: '新規作成成功時は 200 OK ではなく 201 Created を返すことがあります。',
    answer: 'ResponseEntity.status(HttpStatus.CREATED).body(response)',
    explanation:
      'ResponseEntity を使うと、HTTPステータスとレスポンスボディをまとめて明示できます。',
    common_mistakes:
      'ResponseEntity.ok(response) でも動きますが、作成系APIでは CREATED を返す方が意図が伝わりやすいです。',
    display_order: 702,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-007',
    theme_id: 'local-spring-service',
    title: 'Serviceクラスの基本アノテーション',
    level: 1,
    type: 'fill_blank',
    statement:
      'ビジネスロジックを持つクラスとして Spring に管理させたいです。\n空欄に入るアノテーションだけを答えてください。\n\n__________\npublic class TaskService {\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'Controller でも Repository でもない、中間の業務ロジック層です。',
    answer: '@Service',
    explanation:
      '@Service はサービス層のクラスをSpring管理のBeanとして登録するときの代表的なアノテーションです。',
    common_mistakes:
      '@Component でも登録できますが、役割を明確にするために @Service を使う方が読みやすいです。',
    display_order: 801,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-008',
    theme_id: 'local-spring-service',
    title: 'コンストラクタインジェクションの代入',
    level: 2,
    type: 'fill_blank',
    statement:
      'コンストラクタで受け取った repository をフィールドへ代入したいです。\n空欄に入る1行だけを答えてください。\n\n@Service\npublic class TaskService {\n    private final TaskRepository taskRepository;\n\n    public TaskService(TaskRepository taskRepository) {\n        __________\n    }\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: '引数名とフィールド名が同じなので、this を使います。',
    answer: 'this.taskRepository = taskRepository;',
    explanation:
      'コンストラクタインジェクションでは、受け取った依存オブジェクトを final フィールドへ代入する形が基本です。',
    common_mistakes:
      'this を付け忘れると、引数同士の代入になってしまいフィールドが初期化されません。',
    display_order: 802,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-009',
    theme_id: 'local-spring-repository',
    title: 'JPA Repositoryの継承',
    level: 2,
    type: 'fill_blank',
    statement:
      'タスクの永続化を担当する Repository インターフェースを作りたいです。\n空欄に入る継承先だけを答えてください。\n\npublic interface TaskRepository extends __________ {\n}',
    requirements: '空欄には型名だけを書いてください。',
    hint: 'Spring Data JPA の基本形です。',
    answer: 'JpaRepository<Task, Long>',
    explanation:
      'JpaRepository<Entity, ID型> の形で継承すると、基本的なCRUDメソッドを自動で使えるようになります。',
    common_mistakes:
      'ID型を Integer にしてしまう、Entity型を DTO にしてしまう、の2つが初学者で起きやすいミスです。',
    display_order: 803,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-010',
    theme_id: 'local-spring-validation',
    title: '必須入力のバリデーション',
    level: 2,
    type: 'fill_blank',
    statement:
      'タイトルを必須入力にしたいです。\n空欄に入るアノテーションだけを答えてください。\n\npublic class CreateTaskRequest {\n    __________\n    private String title;\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: '空文字や空白だけを弾きたいときに使います。',
    answer: '@NotBlank(message = "title is required")',
    explanation:
      '@NotBlank は null だけでなく空文字や空白文字だけの入力も不正として扱えます。',
    common_mistakes:
      '@NotNull だと空文字を許してしまうため、文字列の必須チェックとしては弱いです。',
    display_order: 901,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-011',
    theme_id: 'local-spring-validation',
    title: 'リクエストDTOに@Validを付ける',
    level: 2,
    type: 'fill_blank',
    statement:
      'CreateTaskRequest に書いたバリデーションを有効にしたいです。\n空欄に入る引数だけを答えてください。\n\n@PostMapping\npublic ResponseEntity<Void> create(__________) {\n    return ResponseEntity.ok().build();\n}',
    requirements: '空欄には引数1つ分だけを書いてください。',
    hint: 'バリデーション対象のDTOには @Valid を付けて受け取ります。',
    answer: '@Valid @RequestBody CreateTaskRequest request',
    explanation:
      '@Valid を付けることで、DTOに書かれたアノテーションベースの入力チェックが実行されます。',
    common_mistakes:
      '@RequestBody だけだとDTOへの変換はされても、バリデーションは走りません。',
    display_order: 902,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-012',
    theme_id: 'local-spring-exception',
    title: '例外ハンドラの対象指定',
    level: 3,
    type: 'fill_blank',
    statement:
      'TaskNotFoundException をまとめて処理したいです。\n空欄に入るアノテーションだけを答えてください。\n\n@ControllerAdvice\npublic class GlobalExceptionHandler {\n\n    __________\n    public ResponseEntity<String> handleTaskNotFound(TaskNotFoundException e) {\n        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());\n    }\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: '特定の例外クラスをハンドラメソッドに結びつけます。',
    answer: '@ExceptionHandler(TaskNotFoundException.class)',
    explanation:
      '@ExceptionHandler を付けると、その例外が発生したときにこのメソッドでレスポンスを組み立てられます。',
    common_mistakes:
      '@ControllerAdvice を付けただけでは、どの例外をどのメソッドで処理するかまでは決まりません。',
    display_order: 903,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-013',
    theme_id: 'local-spring-controller',
    title: 'POSTエンドポイントのマッピング',
    level: 1,
    type: 'fill_blank',
    statement:
      '新規作成用の POST エンドポイントを作りたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@RestController\n@RequestMapping("/tasks")\npublic class TaskController {\n\n    __________\n    public String create() {\n        return "created";\n    }\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'POSTメソッド専用のマッピングです。',
    answer: '@PostMapping',
    explanation:
      '@PostMapping は POST リクエストを受け取るときの基本アノテーションです。',
    common_mistakes:
      '@GetMapping のままにすると、作成系エンドポイントなのに GET 扱いになってしまいます。',
    display_order: 605,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-014',
    theme_id: 'local-spring-controller',
    title: 'クラス単位の共通パス設定',
    level: 1,
    type: 'fill_blank',
    statement:
      'TaskController 配下のURLを /tasks にまとめたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@RestController\n__________\npublic class TaskController {\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'メソッドごとではなく、クラス全体に共通パスを付けます。',
    answer: '@RequestMapping("/tasks")',
    explanation:
      '@RequestMapping をクラスに付けると、そのクラス配下のエンドポイント全体に共通パスを付けられます。',
    common_mistakes:
      '各メソッドに毎回 "/tasks" を書いても動きますが、重複が増えて保守しづらくなります。',
    display_order: 606,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-015',
    theme_id: 'local-spring-request-response',
    title: 'レスポンスDTOをrecordで定義する',
    level: 1,
    type: 'fill_blank',
    statement:
      'タスク一覧のレスポンス用 DTO を record で定義したいです。\n空欄に入る1行だけを答えてください。\n\n__________',
    requirements: 'id と title を持つ record を1行で定義してください。',
    hint: 'Spring Boot 3系や最近のJavaでは、シンプルなレスポンスDTOに record がよく使われます。',
    answer: 'public record TaskResponse(Long id, String title) {}',
    explanation:
      'record は値を持つだけのシンプルなDTOを短く表現できる構文です。',
    common_mistakes:
      'class で書いても間違いではありませんが、この問題では record を使う前提です。',
    display_order: 703,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-016',
    theme_id: 'local-spring-request-response',
    title: 'JSONレスポンスのreturn文',
    level: 2,
    type: 'fill_blank',
    statement:
      'TaskResponse を返すメソッドで、id=1, title=\"first task\" のレスポンスを返したいです。\n空欄に入る return の右辺だけを答えてください。\n\n@GetMapping(\"/sample\")\npublic TaskResponse sample() {\n    return __________;\n}',
    requirements: '空欄には return の右辺だけを書いてください。',
    hint: '戻り値の型が TaskResponse なので、その型のインスタンスを返します。',
    answer: 'new TaskResponse(1L, "first task")',
    explanation:
      'Spring Boot は戻り値のオブジェクトを自動で JSON に変換して返してくれます。',
    common_mistakes:
      'TaskEntity のような別の型を返すと、APIで見せたい項目と内部実装が混ざりやすくなります。',
    display_order: 704,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-017',
    theme_id: 'local-spring-dto',
    title: 'EntityからDTOへ変換する',
    level: 1,
    type: 'fill_blank',
    statement:
      'Task エンティティを TaskResponse に変換したいです。\n空欄に入る return 文の右辺だけを答えてください。\n\nprivate TaskResponse toResponse(Task task) {\n    return __________;\n}',
    requirements: 'id と title をそのまま DTO へ詰め替えてください。',
    hint: 'getter で取り出した値を DTO のコンストラクタへ渡します。',
    answer: 'new TaskResponse(task.getId(), task.getTitle())',
    explanation:
      'Entity から DTO へ必要な項目だけを詰め替えるのは、Spring Boot でよく使う基本パターンです。',
    common_mistakes:
      'Entity 自体をそのまま返すと、不要な項目までAPIに出しやすくなります。',
    display_order: 751,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-018',
    theme_id: 'local-spring-dto',
    title: 'DTOのstatic factoryメソッド名',
    level: 2,
    type: 'fill_blank',
    statement:
      'TaskResponse に、Task から生成する static factory を作りたいです。\n空欄に入るメソッド宣言だけを答えてください。\n\npublic record TaskResponse(Long id, String title) {\n    __________ {\n        return new TaskResponse(task.getId(), task.getTitle());\n    }\n}',
    requirements: 'Task を受け取って TaskResponse を返す static factory の宣言を書いてください。',
    hint: 'static メソッドで DTO を作るときは from という名前がよく使われます。',
    answer: 'public static TaskResponse from(Task task)',
    explanation:
      'DTO生成ロジックを from メソッドに寄せると、呼び出し側を短く保ちやすくなります。',
    common_mistakes:
      '戻り値を Task にしてしまうと、DTOを作るメソッドとして意味がずれてしまいます。',
    display_order: 752,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-019',
    theme_id: 'local-spring-dto',
    title: 'DTOリストへ変換するmap処理',
    level: 2,
    type: 'fill_blank',
    statement:
      'Entity の一覧を DTO の一覧に変換したいです。\n空欄に入る stream の1行だけを答えてください。\n\nreturn tasks.stream()\n    __________\n    .toList();',
    requirements: 'TaskResponse の static factory を使って変換してください。',
    hint: '各要素を別の型へ変換するときは map を使います。',
    answer: '.map(TaskResponse::from)',
    explanation:
      'map は「要素ごとの変換」を行うときに使う Stream API の基本です。',
    common_mistakes:
      'filter は絞り込み用なので、型変換したいときには使いません。',
    display_order: 753,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-020',
    theme_id: 'local-spring-service',
    title: 'Serviceメソッドにトランザクションを付ける',
    level: 2,
    type: 'fill_blank',
    statement:
      '作成処理を1つのトランザクションとして扱いたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@Service\npublic class TaskService {\n\n    __________\n    public TaskResponse create(CreateTaskRequest request) {\n        return null;\n    }\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: '複数のDB操作をまとめて成功・失敗させたいときに使います。',
    answer: '@Transactional',
    explanation:
      '@Transactional を付けると、そのメソッド内のDB処理を1つのトランザクションとして扱えます。',
    common_mistakes:
      'Controller に付けるより、業務処理をまとめる Service に付ける方が役割が分かりやすいです。',
    display_order: 804,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-021',
    theme_id: 'local-spring-service',
    title: '見つからないときに例外を投げる',
    level: 2,
    type: 'fill_blank',
    statement:
      'repository.findById(id) の結果が空なら TaskNotFoundException を投げたいです。\n空欄に入る Optional の右辺だけを答えてください。\n\nTask task = repository.findById(id)\n    __________;',
    requirements: 'TaskNotFoundException(id) を投げる形にしてください。',
    hint: 'Optional から値を取り出し、無ければ例外にしたいときの定番です。',
    answer: '.orElseThrow(() -> new TaskNotFoundException(id))',
    explanation:
      'orElseThrow を使うと、「無いなら例外」という処理を短く明確に書けます。',
    common_mistakes:
      'null を返すだけにすると、呼び出し側で毎回nullチェックが必要になり、漏れやすくなります。',
    display_order: 805,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-022',
    theme_id: 'local-spring-repository',
    title: 'findByIdの戻り値の型',
    level: 1,
    type: 'fill_blank',
    statement:
      'TaskRepository に ID検索メソッドを宣言したいです。\n空欄に入る戻り値の型だけを答えてください。\n\npublic interface TaskRepository extends JpaRepository<Task, Long> {\n    __________ findById(Long id);\n}',
    requirements: '空欄には戻り値の型だけを書いてください。',
    hint: '見つからない可能性があるので、Spring Data JPA では Optional で扱うことが多いです。',
    answer: 'Optional<Task>',
    explanation:
      'findById は「あるかもしれないし、ないかもしれない」検索なので Optional<Task> が自然です。',
    common_mistakes:
      'Task をそのまま返す設計にすると、見つからないケースの扱いが曖昧になりやすいです。',
    display_order: 851,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-023',
    theme_id: 'local-spring-repository',
    title: '状態で絞り込む派生クエリ',
    level: 2,
    type: 'fill_blank',
    statement:
      'status でタスク一覧を検索するメソッドを Repository に追加したいです。\n空欄に入るメソッド宣言だけを答えてください。\n\npublic interface TaskRepository extends JpaRepository<Task, Long> {\n    __________\n}',
    requirements: 'List と String status を使った派生クエリメソッドを書いてください。',
    hint: 'Spring Data JPA では findByXxx の形でメソッド名からクエリを作れます。',
    answer: 'List<Task> findByStatus(String status);',
    explanation:
      'Spring Data JPA は findByStatus のような名前から、自動で検索クエリを組み立ててくれます。',
    common_mistakes:
      'メソッド名が searchStatus などになると、自動派生クエリとして認識されません。',
    display_order: 852,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-024',
    theme_id: 'local-spring-validation',
    title: '最大文字数のバリデーション',
    level: 2,
    type: 'fill_blank',
    statement:
      'タイトルを50文字以内に制限したいです。\n空欄に入るアノテーションだけを答えてください。\n\npublic class CreateTaskRequest {\n    __________\n    private String title;\n}',
    requirements: 'message 付きで最大50文字を表現してください。',
    hint: '文字列の長さ制限には Size を使います。',
    answer: '@Size(max = 50, message = "title must be at most 50 characters")',
    explanation:
      '@Size は文字列の最小文字数・最大文字数を指定できる代表的なバリデーションです。',
    common_mistakes:
      '@NotBlank は必須チェックであって、文字数上限までは見てくれません。',
    display_order: 904,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-025',
    theme_id: 'local-spring-exception',
    title: '例外アドバイスの基本アノテーション',
    level: 1,
    type: 'fill_blank',
    statement:
      '例外処理を1か所にまとめるクラスを作りたいです。\n空欄に入るアノテーションだけを答えてください。\n\n__________\npublic class GlobalExceptionHandler {\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: '複数のControllerで共通化したいときに使うアノテーションです。',
    answer: '@ControllerAdvice',
    explanation:
      '@ControllerAdvice を付けると、複数のControllerに共通する例外処理を1か所へまとめられます。',
    common_mistakes:
      '@RestController を付けても例外処理の共通化クラスにはなりません。',
    display_order: 905,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-026',
    theme_id: 'local-spring-exception',
    title: '404 Not Found を返すreturn文',
    level: 2,
    type: 'fill_blank',
    statement:
      'TaskNotFoundException を受けたときに 404 を返したいです。\n空欄に入る return の右辺だけを答えてください。\n\n@ExceptionHandler(TaskNotFoundException.class)\npublic ResponseEntity<String> handleTaskNotFound(TaskNotFoundException e) {\n    return __________;\n}',
    requirements: 'HttpStatus.NOT_FOUND と e.getMessage() を使ってください。',
    hint: 'ResponseEntity でステータスコードと本文を同時に返します。',
    answer: 'ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage())',
    explanation:
      'ResponseEntity.status(...).body(...) を使うと、エラー時のHTTPステータスと本文を明示できます。',
    common_mistakes:
      'ok() を使うと 200 OK になってしまい、エラーであることがクライアントに伝わりません。',
    display_order: 906,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-027',
    theme_id: 'local-spring-controller',
    title: 'PUTエンドポイントのマッピング',
    level: 2,
    type: 'fill_blank',
    statement:
      '更新用の PUT エンドポイントを作りたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@RestController\n@RequestMapping("/tasks")\npublic class TaskController {\n\n    __________\n    public String update(@PathVariable Long id) {\n        return "updated";\n    }\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'URLに id を含む更新系エンドポイントです。',
    answer: '@PutMapping("/{id}")',
    explanation:
      '@PutMapping("/{id}") を付けると、特定IDの更新用エンドポイントを表現できます。',
    common_mistakes:
      '@PostMapping にすると新規作成と更新の意図が混ざりやすくなります。',
    display_order: 607,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-028',
    theme_id: 'local-spring-controller',
    title: 'DELETEエンドポイントのマッピング',
    level: 2,
    type: 'fill_blank',
    statement:
      '削除用の DELETE エンドポイントを作りたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@RestController\n@RequestMapping("/tasks")\npublic class TaskController {\n\n    __________\n    public void delete(@PathVariable Long id) {\n    }\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'HTTPメソッド名に対応する専用アノテーションがあります。',
    answer: '@DeleteMapping("/{id}")',
    explanation:
      '@DeleteMapping を使うと、削除用エンドポイントであることがメソッド宣言だけで伝わります。',
    common_mistakes:
      '@GetMapping にしてしまうと、副作用のある処理を GET で呼ぶ不自然なAPIになります。',
    display_order: 608,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-029',
    theme_id: 'local-spring-request-response',
    title: 'リクエストDTOをrecordで定義する',
    level: 1,
    type: 'fill_blank',
    statement:
      'タスク作成用のリクエストDTOを record で定義したいです。\n空欄に入る1行だけを答えてください。\n\n__________',
    requirements: 'title と description を受け取る record を1行で定義してください。',
    hint: 'シンプルな入力DTOは record で短く表現できます。',
    answer: 'public record CreateTaskRequest(String title, String description) {}',
    explanation:
      'record は入力値を受け取るだけのシンプルな DTO を短く定義するのに向いています。',
    common_mistakes:
      'record の最後の {} を忘れると定義として成立しません。',
    display_order: 705,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-030',
    theme_id: 'local-spring-request-response',
    title: '一覧取得メソッドの戻り値型',
    level: 1,
    type: 'fill_blank',
    statement:
      'タスク一覧を JSON で返す Controller メソッドの戻り値型を決めたいです。\n空欄に入る型だけを答えてください。\n\n@GetMapping\npublic __________ list() {\n    return service.findAll();\n}',
    requirements: 'TaskResponse の一覧を返す型を書いてください。',
    hint: 'DTOを複数返すので List を使います。',
    answer: 'List<TaskResponse>',
    explanation:
      '一覧APIでは、レスポンスDTOの List をそのまま返す形が基本です。',
    common_mistakes:
      'List<Task> にすると Entity を直接返す設計になり、DTOを使う意味が薄れます。',
    display_order: 706,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-031',
    theme_id: 'local-spring-request-response',
    title: '204 No Content を返す',
    level: 2,
    type: 'fill_blank',
    statement:
      '削除成功時にレスポンス本文なしで 204 No Content を返したいです。\n空欄に入る return の右辺だけを答えてください。\n\n@DeleteMapping("/{id}")\npublic ResponseEntity<Void> delete(@PathVariable Long id) {\n    service.delete(id);\n    return __________;\n}',
    requirements: '空欄には return の右辺だけを書いてください。',
    hint: '本文なしで成功を返す専用メソッドがあります。',
    answer: 'ResponseEntity.noContent().build()',
    explanation:
      'noContent().build() を使うと、204 No Content を簡潔に返せます。',
    common_mistakes:
      'ok().build() にすると 200 OK になるため、削除成功時の意図が少し弱くなります。',
    display_order: 707,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-032',
    theme_id: 'local-spring-request-response',
    title: 'ネストしたレスポンスDTOの定義',
    level: 2,
    type: 'fill_blank',
    statement:
      '担当者情報を含むタスク詳細レスポンスを record で定義したいです。\n空欄に入る1行だけを答えてください。\n\n__________',
    requirements: 'id, title, assignee の3項目を持つ TaskDetailResponse を1行で定義してください。',
    hint: 'assignee には UserResponse 型を使います。',
    answer: 'public record TaskDetailResponse(Long id, String title, UserResponse assignee) {}',
    explanation:
      'レスポンスDTOの中に別DTOを入れると、ネストした JSON 構造を自然に表せます。',
    common_mistakes:
      'assignee を String にしてしまうと、利用者情報を1項目に押し込めてしまいます。',
    display_order: 708,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-033',
    theme_id: 'local-spring-dto',
    title: 'DTOをrecordで定義する',
    level: 1,
    type: 'fill_blank',
    statement:
      'タスク一覧表示用のDTOを定義したいです。\n空欄に入る1行だけを答えてください。\n\n__________',
    requirements: 'id と title を持つ TaskSummaryResponse を1行で定義してください。',
    hint: 'DTO は短く record で表せます。',
    answer: 'public record TaskSummaryResponse(Long id, String title) {}',
    explanation:
      'シンプルなDTOは record にすると、getter やコンストラクタを自分で書かずに済みます。',
    common_mistakes:
      'record 名とファイル名の対応を無視すると、Javaのコンパイル時に混乱しやすいです。',
    display_order: 754,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-034',
    theme_id: 'local-spring-dto',
    title: 'DTOのstatic factoryで返す式',
    level: 1,
    type: 'fill_blank',
    statement:
      'TaskSummaryResponse の from メソッド内で DTO を返したいです。\n空欄に入る return の右辺だけを答えてください。\n\npublic static TaskSummaryResponse from(Task task) {\n    return __________;\n}',
    requirements: 'Task の id と title を使って DTO を作ってください。',
    hint: 'DTOのコンストラクタへ必要な値を渡します。',
    answer: 'new TaskSummaryResponse(task.getId(), task.getTitle())',
    explanation:
      'static factory の中では、必要な項目だけを抜き出してDTOを生成します。',
    common_mistakes:
      'Entity をそのまま返すと、from メソッドが DTO 生成にならなくなります。',
    display_order: 755,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-035',
    theme_id: 'local-spring-dto',
    title: 'DTO生成メソッドの宣言',
    level: 2,
    type: 'fill_blank',
    statement:
      'TaskResponse に Task から生成する factory メソッドを追加したいです。\n空欄に入るメソッド宣言だけを答えてください。\n\npublic record TaskResponse(Long id, String title) {\n    __________ {\n        return new TaskResponse(task.getId(), task.getTitle());\n    }\n}',
    requirements: 'Task を引数に取り TaskResponse を返す static メソッドを書いてください。',
    hint: 'static factory の名前は from がよく使われます。',
    answer: 'public static TaskResponse from(Task task)',
    explanation:
      'from のような static factory を置くと、DTO変換ロジックの置き場所がはっきりします。',
    common_mistakes:
      'public TaskResponse from(Task task) とすると、インスタンスメソッドになって意図が少しずれます。',
    display_order: 756,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-036',
    theme_id: 'local-spring-dto',
    title: 'DTOリストへ変換するstream処理',
    level: 2,
    type: 'fill_blank',
    statement:
      'Task の一覧を TaskResponse の一覧に変換したいです。\n空欄に入る1行だけを答えてください。\n\nreturn tasks.stream()\n    __________\n    .toList();',
    requirements: 'TaskResponse の static factory を使ってください。',
    hint: '各要素を別の型へ変えるときは map を使います。',
    answer: '.map(TaskResponse::from)',
    explanation:
      'map(TaskResponse::from) と書くと、各 Task を TaskResponse に変換できます。',
    common_mistakes:
      'forEach は副作用用なので、別のリストへ変換して返したい場面には向きません。',
    display_order: 757,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-037',
    theme_id: 'local-spring-dto',
    title: 'null安全なDTO変換',
    level: 3,
    type: 'fill_blank',
    statement:
      'task が null なら null を返し、そうでなければ DTO に変換したいです。\n空欄に入る return の右辺だけを答えてください。\n\nprivate TaskResponse toResponse(Task task) {\n    return __________;\n}',
    requirements: '三項演算子を使って null 安全に書いてください。',
    hint: 'null かどうかで分岐して、DTO生成か null を返します。',
    answer: 'task == null ? null : TaskResponse.from(task)',
    explanation:
      '変換前に null チェックを入れると、変換処理で NullPointerException を避けられます。',
    common_mistakes:
      'task.getId() を先に呼ぶと、null のときにその時点で落ちてしまいます。',
    display_order: 758,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-038',
    theme_id: 'local-spring-service',
    title: 'ServiceでRepositoryを受け取るフィールド宣言',
    level: 1,
    type: 'fill_blank',
    statement:
      'TaskService に TaskRepository を保持するフィールドを追加したいです。\n空欄に入る1行だけを答えてください。\n\n@Service\npublic class TaskService {\n    __________\n}',
    requirements: 'final フィールドで宣言してください。',
    hint: 'コンストラクタインジェクション前提の書き方です。',
    answer: 'private final TaskRepository taskRepository;',
    explanation:
      '依存オブジェクトは final フィールドに持つと、初期化後に変わらないことが明確になります。',
    common_mistakes:
      'Repository 型ではなく Entity 型を書いてしまうと、依存対象がずれてしまいます。',
    display_order: 806,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-039',
    theme_id: 'local-spring-service',
    title: '保存後のEntityを受け取る',
    level: 2,
    type: 'fill_blank',
    statement:
      '作成した Task を保存し、その戻り値を saved に受け取りたいです。\n空欄に入る1行だけを答えてください。\n\npublic TaskResponse create(Task task) {\n    __________\n    return TaskResponse.from(saved);\n}',
    requirements: 'repository の save メソッドを使ってください。',
    hint: 'save の戻り値を変数で受け取る形です。',
    answer: 'Task saved = taskRepository.save(task);',
    explanation:
      'save の戻り値を受け取っておくと、保存後の状態を DTO へ変換しやすくなります。',
    common_mistakes:
      'save を呼ぶだけで変数に受けないと、続きの行で saved を使えません。',
    display_order: 807,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-040',
    theme_id: 'local-spring-service',
    title: 'Serviceメソッドの戻り値をDTOにする',
    level: 2,
    type: 'fill_blank',
    statement:
      '作成処理の Service メソッドの宣言を書きたいです。\n空欄に入るメソッド宣言だけを答えてください。\n\n@Service\npublic class TaskService {\n    __________ {\n        return null;\n    }\n}',
    requirements: 'CreateTaskRequest を受け取り、TaskResponse を返す create メソッドにしてください。',
    hint: 'Controller から呼ばれて DTO を返す形です。',
    answer: 'public TaskResponse create(CreateTaskRequest request)',
    explanation:
      'Service が DTO を返す設計にすると、Controller 側が薄く保ちやすくなります。',
    common_mistakes:
      '戻り値を Task にすると、Controller 側でさらに DTO 変換が必要になります。',
    display_order: 808,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-041',
    theme_id: 'local-spring-service',
    title: '削除処理をRepositoryへ委譲する',
    level: 2,
    type: 'fill_blank',
    statement:
      'Service の delete メソッドで、実際の削除を Repository に委譲したいです。\n空欄に入る1行だけを答えてください。\n\npublic void delete(Long id) {\n    __________\n}',
    requirements: 'deleteById を使ってください。',
    hint: 'Repository の基本CRUDメソッドを呼び出します。',
    answer: 'taskRepository.deleteById(id);',
    explanation:
      'Service は業務の流れをまとめ、実際の永続化処理は Repository に委譲するのが基本です。',
    common_mistakes:
      'Service の中で EntityManager を直接触り始めると、責務分割が崩れやすくなります。',
    display_order: 809,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-042',
    theme_id: 'local-spring-repository',
    title: 'saveメソッドの使い方',
    level: 1,
    type: 'fill_blank',
    statement:
      '新しい Task を保存したいです。\n空欄に入る1行だけを答えてください。\n\npublic void create(Task task) {\n    __________\n}',
    requirements: 'Repository の save メソッドを呼んでください。',
    hint: 'JPA Repository の基本CRUDです。',
    answer: 'taskRepository.save(task);',
    explanation:
      'save は新規作成にも更新にも使える、Spring Data JPA の代表的なメソッドです。',
    common_mistakes:
      'add や insert のようなメソッド名は、JpaRepository には用意されていません。',
    display_order: 853,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-043',
    theme_id: 'local-spring-repository',
    title: 'deleteByIdの呼び出し',
    level: 1,
    type: 'fill_blank',
    statement:
      'ID指定で削除したいです。\n空欄に入る1行だけを答えてください。\n\npublic void delete(Long id) {\n    __________\n}',
    requirements: 'deleteById を使ってください。',
    hint: 'JpaRepository が標準で持っています。',
    answer: 'taskRepository.deleteById(id);',
    explanation:
      'IDで削除するだけなら、deleteById をそのまま呼ぶだけで十分です。',
    common_mistakes:
      'findById してから remove しようとすると、不要に手順が増えがちです。',
    display_order: 854,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-044',
    theme_id: 'local-spring-repository',
    title: 'タイトル部分一致の派生クエリ',
    level: 2,
    type: 'fill_blank',
    statement:
      'タイトルに keyword を含むタスク一覧を検索したいです。\n空欄に入るメソッド宣言だけを答えてください。\n\npublic interface TaskRepository extends JpaRepository<Task, Long> {\n    __________\n}',
    requirements: 'keyword を引数に取り、部分一致検索を行うメソッドを書いてください。',
    hint: 'Containing を使うと部分一致検索になります。',
    answer: 'List<Task> findByTitleContaining(String keyword);',
    explanation:
      'findByTitleContaining のような名前を書くと、Spring Data JPA が部分一致検索として解釈してくれます。',
    common_mistakes:
      'contains ではなく Containing という名前規則を使うのがポイントです。',
    display_order: 855,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-045',
    theme_id: 'local-spring-repository',
    title: '存在確認の派生クエリ',
    level: 2,
    type: 'fill_blank',
    statement:
      '同じタイトルのタスクが存在するか確認したいです。\n空欄に入るメソッド宣言だけを答えてください。\n\npublic interface TaskRepository extends JpaRepository<Task, Long> {\n    __________\n}',
    requirements: 'title を受け取って boolean を返す形にしてください。',
    hint: 'existsBy... という命名があります。',
    answer: 'boolean existsByTitle(String title);',
    explanation:
      'existsByXxx は、存在確認専用の派生クエリとしてよく使われます。',
    common_mistakes:
      '戻り値を Task にすると、存在確認なのか検索なのかが曖昧になります。',
    display_order: 856,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-046',
    theme_id: 'local-spring-repository',
    title: '作成日時の降順取得',
    level: 3,
    type: 'fill_blank',
    statement:
      '新しい順にタスク一覧を取得したいです。\n空欄に入るメソッド宣言だけを答えてください。\n\npublic interface TaskRepository extends JpaRepository<Task, Long> {\n    __________\n}',
    requirements: 'createdAt の降順ソートを表すメソッド名にしてください。',
    hint: 'OrderBy...Desc という書き方があります。',
    answer: 'List<Task> findAllByOrderByCreatedAtDesc();',
    explanation:
      'OrderByCreatedAtDesc を付けると、作成日時の降順で一覧を取得する派生クエリとして読めます。',
    common_mistakes:
      'findAllOrderByCreatedAtDesc は規則から外れていて、自動クエリとして解釈されません。',
    display_order: 857,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-047',
    theme_id: 'local-spring-validation',
    title: 'nullを禁止するバリデーション',
    level: 1,
    type: 'fill_blank',
    statement:
      'id が null でないことだけを保証したいです。\n空欄に入るアノテーションだけを答えてください。\n\npublic class UpdateTaskRequest {\n    __________\n    private Long id;\n}',
    requirements: '空欄には1行だけを書いてください。',
    hint: '空文字ではなく null そのものを禁止したい場面です。',
    answer: '@NotNull',
    explanation:
      '@NotNull は null を禁止する最も基本的なバリデーションです。',
    common_mistakes:
      '@NotBlank は String 向けなので、Long に使うのは不自然です。',
    display_order: 907,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-048',
    theme_id: 'local-spring-validation',
    title: '最小文字数と最大文字数をまとめて指定する',
    level: 2,
    type: 'fill_blank',
    statement:
      'タイトルを1文字以上50文字以下に制限したいです。\n空欄に入るアノテーションだけを答えてください。\n\npublic class CreateTaskRequest {\n    __________\n    private String title;\n}',
    requirements: 'message なしで構いません。',
    hint: 'Size は min と max を同時に指定できます。',
    answer: '@Size(min = 1, max = 50)',
    explanation:
      '@Size(min = 1, max = 50) と書くと、文字数の下限と上限を一度に指定できます。',
    common_mistakes:
      '@NotBlank だけでは最大文字数の制御まではできません。',
    display_order: 908,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-049',
    theme_id: 'local-spring-validation',
    title: 'BindingResultを受け取る',
    level: 2,
    type: 'fill_blank',
    statement:
      'バリデーション結果をメソッド引数で受け取りたいです。\n空欄に入る引数だけを答えてください。\n\n@PostMapping\npublic ResponseEntity<Void> create(@Valid @RequestBody CreateTaskRequest request, __________) {\n    return ResponseEntity.ok().build();\n}',
    requirements: '空欄には引数1つ分だけを書いてください。',
    hint: 'バリデーションエラーを後続処理で確認するときに使います。',
    answer: 'BindingResult bindingResult',
    explanation:
      'BindingResult を使うと、バリデーションエラーの有無や内容をメソッド内で確認できます。',
    common_mistakes:
      'BindingResult は @Valid の直後に置くのが基本です。',
    display_order: 909,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-050',
    theme_id: 'local-spring-validation',
    title: 'バリデーションエラーの有無を確認する',
    level: 2,
    type: 'fill_blank',
    statement:
      'BindingResult にエラーがあるか確認したいです。\n空欄に入る条件式だけを答えてください。\n\nif (__________) {\n    return ResponseEntity.badRequest().build();\n}',
    requirements: 'bindingResult を使った条件式を書いてください。',
    hint: 'エラーがあるかどうかをそのまま返すメソッドがあります。',
    answer: 'bindingResult.hasErrors()',
    explanation:
      'hasErrors() は、BindingResult に1件でもエラーがあるかを調べる基本メソッドです。',
    common_mistakes:
      'isEmpty() のようなメソッドは BindingResult にはありません。',
    display_order: 910,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-051',
    theme_id: 'local-spring-validation',
    title: 'カスタムバリデーション用のアノテーションを付ける',
    level: 3,
    type: 'fill_blank',
    statement:
      '独自に作った TaskTitle アノテーションで title を検証したいです。\n空欄に入るアノテーションだけを答えてください。\n\npublic class CreateTaskRequest {\n    __________\n    private String title;\n}',
    requirements: 'TaskTitle というカスタムアノテーションを付けてください。',
    hint: '独自に定義した制約アノテーションをそのままフィールドに付けます。',
    answer: '@TaskTitle',
    explanation:
      'カスタムバリデーションは、作成済みの独自アノテーションをフィールドへ付けて使います。',
    common_mistakes:
      '@TaskTitleValidator のように、Validatorクラス名をそのまま付けるわけではありません。',
    display_order: 911,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-052',
    theme_id: 'local-spring-exception',
    title: 'カスタム例外クラスの継承元',
    level: 1,
    type: 'fill_blank',
    statement:
      'TaskNotFoundException を実行時例外として作りたいです。\n空欄に入る継承元だけを答えてください。\n\npublic class TaskNotFoundException extends __________ {\n}',
    requirements: '空欄には型名だけを書いてください。',
    hint: 'チェック例外にしたくないので、実行時例外を使います。',
    answer: 'RuntimeException',
    explanation:
      'RuntimeException を継承すると、呼び出し側へ throws を強制しないカスタム例外になります。',
    common_mistakes:
      'Exception を継承すると、毎回 throws / try-catch を強制しやすくなります。',
    display_order: 951,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-053',
    theme_id: 'local-spring-exception',
    title: '例外コンストラクタのsuper呼び出し',
    level: 1,
    type: 'fill_blank',
    statement:
      'TaskNotFoundException のコンストラクタでメッセージを親クラスへ渡したいです。\n空欄に入る1行だけを答えてください。\n\npublic TaskNotFoundException(String message) {\n    __________\n}',
    requirements: 'message を親クラスへ渡してください。',
    hint: '例外メッセージは親の RuntimeException に保持させます。',
    answer: 'super(message);',
    explanation:
      'super(message) と書くと、例外メッセージを RuntimeException 側へ渡せます。',
    common_mistakes:
      'this.message = message のように自前で保持すると、例外標準の仕組みを活かせません。',
    display_order: 952,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-054',
    theme_id: 'local-spring-exception',
    title: 'バリデーション例外を受けるアノテーション',
    level: 2,
    type: 'fill_blank',
    statement:
      'MethodArgumentNotValidException を処理するハンドラを作りたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@ControllerAdvice\npublic class GlobalExceptionHandler {\n\n    __________\n    public ResponseEntity<String> handleValidation(MethodArgumentNotValidException e) {\n        return ResponseEntity.badRequest().body("validation error");\n    }\n}',
    requirements: '対象例外クラスを指定してください。',
    hint: 'TaskNotFoundException のときと同じ書き方で、例外クラスだけ変わります。',
    answer: '@ExceptionHandler(MethodArgumentNotValidException.class)',
    explanation:
      '@ExceptionHandler(例外クラス.class) で、どの例外をこのメソッドが受けるかを指定できます。',
    common_mistakes:
      '"@ExceptionHandler(MethodArgumentNotValidException)" のように .class を忘れると文法上成立しません。',
    display_order: 953,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-055',
    theme_id: 'local-spring-exception',
    title: 'エラーレスポンスDTOの定義',
    level: 2,
    type: 'fill_blank',
    statement:
      'errorCode と message を持つエラーレスポンスDTOを record で定義したいです。\n空欄に入る1行だけを答えてください。\n\n__________',
    requirements: 'ErrorResponse という名前で1行定義してください。',
    hint: '通常のレスポンスDTOと同じく record が使えます。',
    answer: 'public record ErrorResponse(String errorCode, String message) {}',
    explanation:
      'エラー時専用の DTO を分けておくと、クライアント側が扱いやすいレスポンス構造になります。',
    common_mistakes:
      'Map をその場で返すより、型を作っておく方が後から見ても意味が分かりやすいです。',
    display_order: 954,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-056',
    theme_id: 'local-spring-exception',
    title: '例外ハンドラでエラーレスポンスを返す',
    level: 3,
    type: 'fill_blank',
    statement:
      'TaskNotFoundException のハンドラで ErrorResponse を返したいです。\n空欄に入る return の右辺だけを答えてください。\n\n@ExceptionHandler(TaskNotFoundException.class)\npublic ResponseEntity<ErrorResponse> handleTaskNotFound(TaskNotFoundException e) {\n    return __________;\n}',
    requirements: '404 と ErrorResponse("TASK_NOT_FOUND", e.getMessage()) を使ってください。',
    hint: 'ResponseEntity.status(...).body(...) の形です。',
    answer: 'ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorResponse("TASK_NOT_FOUND", e.getMessage()))',
    explanation:
      '例外ハンドラで専用DTOを返すと、エラー時のレスポンス形式を統一しやすくなります。',
    common_mistakes:
      '文字列だけ返すと、エラーコードのような機械判定向け情報を持たせにくくなります。',
    display_order: 955,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-057',
    theme_id: 'local-spring-controller',
    title: 'GET詳細取得エンドポイントを実装する',
    level: 2,
    type: 'normal',
    statement:
      'TaskController に、id を受け取って TaskResponse を返す GET エンドポイントを実装してください。',
    requirements:
      'メソッド名は getTask とすること。\n@PathVariable Long id を受け取ること。\nservice.getTask(id) の結果を返すこと。\n@GetMapping("/{id}") を付けること。',
    hint: 'Controller は薄く保ち、実際の取得処理は service に委譲します。',
    answer:
      '@GetMapping("/{id}")\npublic TaskResponse getTask(@PathVariable Long id) {\n    return taskService.getTask(id);\n}',
    explanation:
      'Spring Boot の Controller では、URLから受け取った値を引数で受け、サービス層へ処理を委譲する形が基本です。',
    common_mistakes:
      'Controller の中で直接 repository を呼び始めると、責務が混ざりやすくなります。',
    display_order: 956,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-058',
    theme_id: 'local-spring-controller',
    title: '削除エンドポイントを実装する',
    level: 2,
    type: 'normal',
    statement:
      'TaskController に、id 指定でタスクを削除する DELETE エンドポイントを実装してください。',
    requirements:
      'メソッド名は deleteTask とすること。\n@PathVariable Long id を受け取ること。\nservice.delete(id) を呼ぶこと。\n戻り値は ResponseEntity<Void> とし、204 No Content を返すこと。',
    hint: '本文を返さない成功レスポンスには noContent().build() が使えます。',
    answer:
      '@DeleteMapping("/{id}")\npublic ResponseEntity<Void> deleteTask(@PathVariable Long id) {\n    taskService.delete(id);\n    return ResponseEntity.noContent().build();\n}',
    explanation:
      '削除成功時は本文なしの 204 No Content を返すと、APIの意図が分かりやすくなります。',
    common_mistakes:
      '200 OK を返しても動きますが、削除成功としては 204 の方が意味が伝わりやすいです。',
    display_order: 957,
    themes: createSpringBootTheme('Spring Boot: Controller基礎'),
  },
  {
    id: 'local-spring-boot-059',
    theme_id: 'local-spring-request-response',
    title: '作成用リクエストDTOを定義する',
    level: 2,
    type: 'normal',
    statement:
      'タイトルと説明文を受け取る CreateTaskRequest を record で定義してください。',
    requirements:
      'クラス名は CreateTaskRequest とすること。\ntitle と description を持つこと。\nrecord を使うこと。',
    hint: 'Spring Boot のシンプルな入力DTOは record で十分なことが多いです。',
    answer:
      'public record CreateTaskRequest(String title, String description) {\n}',
    explanation:
      'record を使うと、入力を受け取るだけの DTO を短く定義できます。',
    common_mistakes:
      'getter やコンストラクタを自分で長く書き始めると、シンプルなDTOの利点が減ってしまいます。',
    display_order: 958,
    themes: createSpringBootTheme('Spring Boot: Request / Response'),
  },
  {
    id: 'local-spring-boot-060',
    theme_id: 'local-spring-dto',
    title: 'EntityからDTOへ変換するfromメソッドを実装する',
    level: 2,
    type: 'normal',
    statement:
      'TaskResponse に、Task エンティティから DTO を作る from メソッドを実装してください。',
    requirements:
      'public static TaskResponse from(Task task) とすること。\nTask の id と title を TaskResponse に詰め替えること。',
    hint: 'static factory にしておくと、呼び出し側で map(TaskResponse::from) と書きやすくなります。',
    answer:
      'public static TaskResponse from(Task task) {\n    return new TaskResponse(task.getId(), task.getTitle());\n}',
    explanation:
      'Entity をそのまま返さず DTO へ変換することで、APIが外へ見せる項目をコントロールしやすくなります。',
    common_mistakes:
      'DTO 変換ロジックをあちこちに散らすと、項目変更時の修正漏れが起きやすくなります。',
    display_order: 959,
    themes: createSpringBootTheme('Spring Boot: DTO'),
  },
  {
    id: 'local-spring-boot-061',
    theme_id: 'local-spring-service',
    title: 'ID検索してDTOを返すServiceメソッドを実装する',
    level: 3,
    type: 'normal',
    statement:
      'TaskService に、id でタスクを取得して TaskResponse を返す getTask メソッドを実装してください。',
    requirements:
      '引数は Long id とすること。\nrepository.findById(id) を使うこと。\n見つからない場合は TaskNotFoundException(id) を投げること。\n見つかった Task は TaskResponse.from(task) で返すこと。',
    hint: 'Optional から値を取り出すときは orElseThrow が便利です。',
    answer:
      'public TaskResponse getTask(Long id) {\n    Task task = taskRepository.findById(id)\n        .orElseThrow(() -> new TaskNotFoundException(id));\n    return TaskResponse.from(task);\n}',
    explanation:
      'Service 層では検索、例外化、DTO 変換の流れをまとめて扱うことが多いです。',
    common_mistakes:
      'null を返してしまうと、呼び出し側へ責務が漏れて Controller 側の分岐が増えやすくなります。',
    display_order: 960,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-062',
    theme_id: 'local-spring-service',
    title: '作成処理をServiceへ移す',
    level: 3,
    type: 'normal',
    statement:
      'CreateTaskRequest を受け取り、Task を保存して TaskResponse を返す create メソッドを TaskService に実装してください。',
    requirements:
      '引数は CreateTaskRequest request とすること。\nnew Task(request.title(), request.description()) で生成すること。\nrepository.save(task) を使うこと。\n保存後は TaskResponse.from(saved) で返すこと。',
    hint: 'Controller ではなく Service に作成処理を置くと責務が整理しやすくなります。',
    answer:
      'public TaskResponse create(CreateTaskRequest request) {\n    Task task = new Task(request.title(), request.description());\n    Task saved = taskRepository.save(task);\n    return TaskResponse.from(saved);\n}',
    explanation:
      '作成処理は Service に置き、Controller は入出力の受け渡しに寄せる方が保守しやすいです。',
    common_mistakes:
      'Controller の中で Entity を組み立て始めると、層の役割が曖昧になりやすくなります。',
    display_order: 961,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-063',
    theme_id: 'local-spring-repository',
    title: 'Repositoryに派生クエリを定義する',
    level: 2,
    type: 'normal',
    statement:
      'TaskRepository に、status で絞り込んだ一覧取得メソッドと title の部分一致検索メソッドを定義してください。',
    requirements:
      'TaskRepository は JpaRepository<Task, Long> を継承している前提。\nfindByStatus(String status) を書くこと。\nfindByTitleContaining(String keyword) を書くこと。',
    hint: 'Spring Data JPA はメソッド名からクエリを自動生成できます。',
    answer:
      'public interface TaskRepository extends JpaRepository<Task, Long> {\n    List<Task> findByStatus(String status);\n    List<Task> findByTitleContaining(String keyword);\n}',
    explanation:
      'findByXxx や Containing を使った派生クエリは、初学者が最初に覚えやすい Spring Data JPA の強みです。',
    common_mistakes:
      'searchByTitle のような自由な命名にすると、自動派生クエリとして認識されません。',
    display_order: 962,
    themes: createSpringBootTheme('Spring Boot: Repository'),
  },
  {
    id: 'local-spring-boot-064',
    theme_id: 'local-spring-validation',
    title: 'リクエストDTOへ入力バリデーションを付ける',
    level: 2,
    type: 'normal',
    statement:
      'CreateTaskRequest の title に、必須かつ最大50文字のバリデーションを付けてください。',
    requirements:
      'title フィールドに @NotBlank を付けること。\nさらに @Size(max = 50) を付けること。\nrecord ではなく class で書いてよい。',
    hint: '必須と文字数上限は別アノテーションで表現します。',
    answer:
      'public class CreateTaskRequest {\n    @NotBlank\n    @Size(max = 50)\n    private String title;\n}',
    explanation:
      '入力検証は「必須」と「長さ上限」のように、意味ごとにアノテーションを分けて付けるのが基本です。',
    common_mistakes:
      '@NotBlank だけでは最大文字数は制御できません。',
    display_order: 963,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-065',
    theme_id: 'local-spring-validation',
    title: 'Controllerで@Validを付けて受け取る',
    level: 2,
    type: 'normal',
    statement:
      'TaskController の作成エンドポイントで、CreateTaskRequest のバリデーションを有効にした状態で受け取るメソッドを実装してください。',
    requirements:
      'メソッド名は createTask とすること。\n@PostMapping を付けること。\n引数で @Valid @RequestBody CreateTaskRequest request を受け取ること。\nservice.create(request) の結果を返すこと。',
    hint: 'DTO側のバリデーションは、Controller側で @Valid を付けて初めて実行されます。',
    answer:
      '@PostMapping\npublic TaskResponse createTask(@Valid @RequestBody CreateTaskRequest request) {\n    return taskService.create(request);\n}',
    explanation:
      'DTO に制約を書くだけでは不十分で、受け取り側で @Valid を付ける必要があります。',
    common_mistakes:
      '@RequestBody だけだと JSON 変換はされても、バリデーションは走りません。',
    display_order: 964,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
  {
    id: 'local-spring-boot-066',
    theme_id: 'local-spring-exception',
    title: 'TaskNotFoundExceptionを404へ変換する',
    level: 3,
    type: 'normal',
    statement:
      'GlobalExceptionHandler に、TaskNotFoundException を受けて 404 の ErrorResponse を返すハンドラメソッドを実装してください。',
    requirements:
      '@ExceptionHandler(TaskNotFoundException.class) を付けること。\n戻り値は ResponseEntity<ErrorResponse> とすること。\n本文には new ErrorResponse("TASK_NOT_FOUND", e.getMessage()) を返すこと。\nHTTPステータスは NOT_FOUND とすること。',
    hint: 'ResponseEntity.status(HttpStatus.NOT_FOUND).body(...) の形です。',
    answer:
      '@ExceptionHandler(TaskNotFoundException.class)\npublic ResponseEntity<ErrorResponse> handleTaskNotFound(TaskNotFoundException e) {\n    return ResponseEntity.status(HttpStatus.NOT_FOUND)\n        .body(new ErrorResponse("TASK_NOT_FOUND", e.getMessage()));\n}',
    explanation:
      '例外を API 向けの統一レスポンスへ変換すると、クライアント側で扱いやすい失敗レスポンスになります。',
    common_mistakes:
      '文字列だけ返すと、エラーコードのような機械判定用の情報を含めにくくなります。',
    display_order: 965,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-067',
    theme_id: 'local-spring-service',
    title: '更新API用のServiceメソッドを書く',
    level: 3,
    type: 'normal',
    statement:
      '`TaskUpdateRequest request` を受け取り、既存タスクを更新して `TaskResponse` を返す `update` メソッドを `TaskService` に書いてください。',
    requirements:
      '引数は `Long id, TaskUpdateRequest request` とすること\n`findById(id)` と `orElseThrow` を使うこと\nタイトルと説明文を更新すること\n`save` 後に `TaskResponse.from(saved)` を返すこと',
    hint: '更新系でも、新規作成と同じく Service に処理を寄せて Controller は薄く保つのが基本です。',
    answer:
      'public TaskResponse update(Long id, TaskUpdateRequest request) {\n    Task task = taskRepository.findById(id)\n        .orElseThrow(() -> new TaskNotFoundException(id));\n    task.setTitle(request.title());\n    task.setDescription(request.description());\n    Task saved = taskRepository.save(task);\n    return TaskResponse.from(saved);\n}',
    explanation:
      '研修では「既存データを取得して更新し、保存して DTO へ変換する」一連の流れを自力で書けるかがよく問われます。',
    common_mistakes:
      '更新なのに毎回 `new Task(...)` を作ると、既存データの変更ではなく新規作成に寄ってしまいます。',
    display_order: 966,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-068',
    theme_id: 'local-spring-controller',
    title: '作成APIで201 Createdを返すControllerを書く',
    level: 3,
    type: 'normal',
    statement:
      '`CreateTaskRequest` を受け取り、作成成功時に `201 Created` で `TaskResponse` を返す `POST /tasks` の Controller メソッドを書いてください。',
    requirements:
      '`@PostMapping` を使うこと\n引数に `@Valid @RequestBody CreateTaskRequest request` を取ること\n戻り値は `ResponseEntity<TaskResponse>` にすること\n`HttpStatus.CREATED` を使うこと',
    hint: '単に DTO を返すだけでなく、作成系らしいステータスコードまで含めて書く問題です。',
    answer:
      '@PostMapping\npublic ResponseEntity<TaskResponse> createTask(@Valid @RequestBody CreateTaskRequest request) {\n    TaskResponse response = taskService.create(request);\n    return ResponseEntity.status(HttpStatus.CREATED).body(response);\n}',
    explanation:
      '研修では REST API の作成系で `201 Created` を返せるかどうかも見られやすいポイントです。',
    common_mistakes:
      '作成成功でも常に `200 OK` だけ返すと、API の意図が伝わりにくくなります。',
    display_order: 967,
    themes: createSpringBootTheme('Spring Boot: Controller'),
  },
  {
    id: 'local-spring-boot-069',
    theme_id: 'local-spring-exception',
    title: 'GET詳細が404になるときの確認点を書く',
    level: 3,
    type: 'normal',
    statement:
      '`GET /tasks/1` へアクセスすると 404 が返ってきます。最初に確認したいポイントを2つ書いてください。',
    requirements:
      'Controller の `@GetMapping` と `@PathVariable` の対応を書くこと\nDB に該当 id のデータが存在するか、または `findById` の結果確認を書くこと',
    hint: '最初から複雑に考えず、「ルーティングが合っているか」と「データがあるか」を分けて確認します。',
    answer:
      '1. Controller の `@GetMapping("/{id}")` と `@PathVariable Long id` の対応が正しいか確認する\n2. `findById(1)` で対象データが実際に存在するか確認する',
    explanation:
      '研修の不具合対応では、まず入口のルーティングとデータ存在確認を分けて見る癖が大切です。',
    common_mistakes:
      'いきなり細かいフレームワーク設定を疑うより、最初は URL 対応とデータ有無を押さえる方が精度が高いです。',
    display_order: 968,
    themes: createSpringBootTheme('Spring Boot: Exception Handling'),
  },
  {
    id: 'local-spring-boot-070',
    theme_id: 'local-spring-request-response',
    title: '@RequestBody がなくて JSON を受け取れないバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次の Controller では `POST /tasks` に JSON を送っても `title` が入ってきません。原因を直したメソッドを書いてください。\n\n```java\n@PostMapping("/tasks")\npublic TaskResponse createTask(CreateTaskRequest request) {\n    return taskService.create(request);\n}\n```',
    requirements:
      '`@RequestBody` を追加すること\n必要なら `@Valid` も付けること\nメソッド全体を正しい形で書くこと',
    hint: 'Spring Boot で JSON のリクエストボディを DTO に変換するときに必要なアノテーションを思い出してください。',
    answer:
      '@PostMapping("/tasks")\npublic TaskResponse createTask(@Valid @RequestBody CreateTaskRequest request) {\n    return taskService.create(request);\n}',
    explanation:
      'JSON を DTO にマッピングするには `@RequestBody` が必要です。入力チェックも行うなら `@Valid` を一緒に付けるのが自然です。',
    common_mistakes:
      '`@RequestParam` に変えてしまうと JSON 本文の受け取りにはなりません。POST の本文を読むケースでは `@RequestBody` を使います。',
    display_order: 969,
    themes: createSpringBootTheme('Spring Boot: Request-Response'),
  },
  {
    id: 'local-spring-boot-071',
    theme_id: 'local-spring-service',
    title: 'findById().get() で落ちる Service のバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次の Service は、存在しない ID を指定すると例外で落ちます。`TaskNotFoundException` を投げるように修正したコードを書いてください。\n\n```java\npublic TaskResponse getTask(Long id) {\n    Task task = taskRepository.findById(id).get();\n    return TaskResponse.from(task);\n}\n```',
    requirements:
      '`findById` の戻り値を安全に扱うこと\n見つからないときは `TaskNotFoundException` を投げること\n最後に `TaskResponse.from(task)` を返すこと',
    hint: 'Repository から 1 件取得するときは `Optional` をそのまま `.get()` せず、見つからない場合を明示的に処理するのが基本です。',
    answer:
      'public TaskResponse getTask(Long id) {\n    Task task = taskRepository.findById(id)\n        .orElseThrow(() -> new TaskNotFoundException(id));\n    return TaskResponse.from(task);\n}',
    explanation:
      '`findById(...).get()` はデータがないと `NoSuchElementException` になります。業務では意味のある例外に置き換えておく方が API の挙動が分かりやすくなります。',
    common_mistakes:
      '`null` を返してしまうと Controller 側で別の `NullPointerException` を生みやすくなります。見つからないケースはその場で例外に寄せる方が安全です。',
    display_order: 970,
    themes: createSpringBootTheme('Spring Boot: Service'),
  },
  {
    id: 'local-spring-boot-072',
    theme_id: 'local-spring-validation',
    title: '@Valid を付け忘れてバリデーションが効かないバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次の Controller では `CreateTaskRequest` に `@NotBlank` が付いていても入力チェックが動きません。修正後のメソッドを書いてください。\n\n```java\n@PostMapping("/tasks")\npublic TaskResponse createTask(@RequestBody CreateTaskRequest request) {\n    return taskService.create(request);\n}\n```',
    requirements:
      '引数のどこを直すか明確にすること\n`@RequestBody` は残すこと\n必要ならメソッド全体を書き直してよい',
    hint: 'DTO に付けたバリデーションを Controller で有効にするためのアノテーションを確認してください。',
    answer:
      '@PostMapping("/tasks")\npublic TaskResponse createTask(@Valid @RequestBody CreateTaskRequest request) {\n    return taskService.create(request);\n}',
    explanation:
      'DTO 側に制約アノテーションがあっても、Controller 引数に `@Valid` がないと検証は実行されません。',
    common_mistakes:
      'DTO クラス側だけ見直しても Controller の受け口がそのままだと直りません。バリデーション開始の起点は引数の `@Valid` です。',
    display_order: 971,
    themes: createSpringBootTheme('Spring Boot: Validation'),
  },
]

export const LOCAL_AWS_PROBLEMS: ProblemRecord[] = [
  {
    id: 'local-aws-001',
    theme_id: 'local-aws-ec2',
    title: 'EC2の正式名称',
    level: 1,
    type: 'fill_blank',
    statement:
      'EC2 の正式名称を答えてください。\n空欄に入る英語だけを答えてください。\n\nAmazon __________',
    requirements: '空欄には2単語を書いてください。',
    hint: '仮想サーバーを提供する代表的なAWSサービスです。',
    answer: 'Elastic Compute',
    explanation:
      'EC2 は Amazon Elastic Compute Cloud の略で、仮想サーバーを起動できるサービスです。',
    common_mistakes:
      'Cloud まで含めた正式名称は Elastic Compute Cloud ですが、空欄は EC2 の E と C に対応する部分だけです。',
    display_order: 1101,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-002',
    theme_id: 'local-aws-ec2',
    title: 'EC2インスタンスへ接続するプロトコル',
    level: 1,
    type: 'fill_blank',
    statement:
      'Linux の EC2 インスタンスへリモート接続するときによく使うプロトコルを答えてください。\n空欄に入る略称だけを答えてください。\n\n__________ 接続',
    requirements: '空欄には大文字の略称を書いてください。',
    hint: '22番ポートを使うことが多い接続方式です。',
    answer: 'SSH',
    explanation:
      'EC2 へ安全にリモート接続するときは SSH を使うのが基本です。',
    common_mistakes:
      'HTTP や HTTPS はWebアクセス用であり、サーバーへログインするための接続方式ではありません。',
    display_order: 1102,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-003',
    theme_id: 'local-aws-ec2',
    title: 'Web公開で開ける代表ポート',
    level: 1,
    type: 'fill_blank',
    statement:
      'HTTP でWebアプリを公開するとき、セキュリティグループで許可する代表的なポート番号を答えてください。\n\nポート __________',
    requirements: '空欄には数字だけを書いてください。',
    hint: 'ブラウザで http:// から始まる通信に使います。',
    answer: '80',
    explanation:
      'HTTP の標準ポートは 80 です。WebアプリをHTTP公開するときはこのポートを開けます。',
    common_mistakes:
      '443 は HTTPS 用の標準ポートであり、HTTP とは別です。',
    display_order: 1103,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-004',
    theme_id: 'local-aws-ec2',
    title: 'JavaアプリをEC2で起動するコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      'task-app.jar を EC2 上で起動したいです。\n空欄に入るコマンド全体を答えてください。\n\n__________',
    requirements: 'jar ファイルを起動する基本コマンドを書いてください。',
    hint: 'Javaのjar実行コマンドです。',
    answer: 'java -jar task-app.jar',
    explanation:
      'Spring Boot の jar は java -jar で起動するのが基本です。',
    common_mistakes:
      'javac はコンパイル用なので、すでに出来上がった jar の起動には使いません。',
    display_order: 1104,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-005',
    theme_id: 'local-aws-ec2',
    title: 'EC2の公開IPを確認する目的',
    level: 2,
    type: 'fill_blank',
    statement:
      'EC2 の公開IPアドレスをブラウザから使うときのURLの形を答えてください。\n空欄に入る形式だけを答えてください。\n\nhttp://__________',
    requirements: 'EC2 の公開IPをそのまま使う形で答えてください。',
    hint: '例として 1.2.3.4 のようなIPを入れる場所です。',
    answer: '<public-ip>',
    explanation:
      '公開IP を使うと、DNS未設定でもブラウザからアプリの疎通確認ができます。',
    common_mistakes:
      'localhost は自分のPCを指すため、EC2確認用のURLにはなりません。',
    display_order: 1105,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-006',
    theme_id: 'local-aws-ec2',
    title: 'EC2インスタンスの起動単位',
    level: 2,
    type: 'fill_blank',
    statement:
      'AWS で仮想サーバー1台分を表す単位名を答えてください。\n\nEC2 __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'EC2でサーバーを作るときによく使う呼び方です。',
    answer: 'instance',
    explanation:
      'EC2 では仮想サーバー1台を instance と呼びます。',
    common_mistakes:
      'container は ECS や Docker 周辺で使う言葉で、EC2 の基本単位とは別です。',
    display_order: 1106,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-007',
    theme_id: 'local-aws-s3',
    title: 'S3の保存単位',
    level: 1,
    type: 'fill_blank',
    statement:
      'S3 でファイルを保存する入れ物の単位名を答えてください。\n\nS3 __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'フォルダではなく、S3特有の呼び方があります。',
    answer: 'bucket',
    explanation:
      'S3 は bucket という単位の中にオブジェクトを保存します。',
    common_mistakes:
      'folder のように見えても、S3の基本単位は bucket と object です。',
    display_order: 1201,
    themes: createAwsTheme('AWS: S3'),
  },
  {
    id: 'local-aws-008',
    theme_id: 'local-aws-s3',
    title: 'S3に保存されるファイルの呼び方',
    level: 1,
    type: 'fill_blank',
    statement:
      'S3 に保存されるファイル1件を AWS では何と呼ぶか答えてください。\n\nS3 __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'バケットの中に保存される単位です。',
    answer: 'object',
    explanation:
      'S3 では保存されるデータ1件を object と呼びます。',
    common_mistakes:
      'record や file でも意味は通じますが、AWSの正式な用語では object です。',
    display_order: 1202,
    themes: createAwsTheme('AWS: S3'),
  },
  {
    id: 'local-aws-009',
    theme_id: 'local-aws-s3',
    title: 'S3で静的サイトを公開する設定名',
    level: 2,
    type: 'fill_blank',
    statement:
      'S3 バケットで HTML を公開する機能名を答えてください。\n\nStatic Website __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'S3でWebページをそのまま配信する機能です。',
    answer: 'Hosting',
    explanation:
      'S3 には Static Website Hosting という機能があり、静的サイト公開に使えます。',
    common_mistakes:
      'Streaming は動画配信周辺で使う言葉で、静的サイト公開の正式名ではありません。',
    display_order: 1203,
    themes: createAwsTheme('AWS: S3'),
  },
  {
    id: 'local-aws-010',
    theme_id: 'local-aws-s3',
    title: 'S3のアクセス制御でよく使う設定',
    level: 2,
    type: 'fill_blank',
    statement:
      'S3 オブジェクトへ誰がアクセスできるかを定義する代表的な仕組みを答えてください。\n\n__________ policy',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'バケット単位で付けることが多いです。',
    answer: 'Bucket',
    explanation:
      'S3 では bucket policy を使ってアクセス許可をまとめて制御することがよくあります。',
    common_mistakes:
      'Security group は EC2 や RDS のネットワーク制御で、S3のアクセス制御とは別です。',
    display_order: 1204,
    themes: createAwsTheme('AWS: S3'),
  },
  {
    id: 'local-aws-011',
    theme_id: 'local-aws-rds',
    title: 'RDSの正式名称',
    level: 1,
    type: 'fill_blank',
    statement:
      'RDS の正式名称を答えてください。\n\nAmazon Relational Database __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'RDS の S に対応する単語です。',
    answer: 'Service',
    explanation:
      'RDS は Amazon Relational Database Service の略です。',
    common_mistakes:
      'System ではなく Service です。',
    display_order: 1301,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-012',
    theme_id: 'local-aws-rds',
    title: 'Spring BootのDB接続URL先',
    level: 2,
    type: 'fill_blank',
    statement:
      'Spring Boot から RDS に接続するとき、application.properties の接続先プロパティ名を答えてください。\n\nspring.datasource.__________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'JDBC接続文字列を入れる場所です。',
    answer: 'url',
    explanation:
      'spring.datasource.url に RDS への JDBC URL を設定するのが基本です。',
    common_mistakes:
      'host だけでは接続文字列として不十分で、Spring Boot の標準プロパティ名とも違います。',
    display_order: 1302,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-013',
    theme_id: 'local-aws-rds',
    title: 'RDS接続で必要な認証情報',
    level: 2,
    type: 'fill_blank',
    statement:
      'Spring Boot の RDS 接続設定で、ユーザー名を入れるプロパティ名を答えてください。\n\nspring.datasource.__________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'password と対になる設定です。',
    answer: 'username',
    explanation:
      'spring.datasource.username に DB ユーザー名を設定します。',
    common_mistakes:
      'user ではなく username が Spring Boot の標準プロパティ名です。',
    display_order: 1303,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-014',
    theme_id: 'local-aws-rds',
    title: 'RDSを公開しすぎないための制御',
    level: 2,
    type: 'fill_blank',
    statement:
      'EC2 から RDS への通信許可をネットワークレベルで制御するとき、よく使うAWS機能を答えてください。\n\nSecurity __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'EC2でもRDSでも使う通信ルールです。',
    answer: 'Group',
    explanation:
      'RDS への接続元やポートの制御には Security Group を使うのが基本です。',
    common_mistakes:
      'IAM は誰が使えるかの制御であり、ネットワーク通信の許可ではありません。',
    display_order: 1304,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-015',
    theme_id: 'local-aws-rds',
    title: 'JavaからDBへつなぐ標準API',
    level: 1,
    type: 'fill_blank',
    statement:
      'Java アプリから RDS のようなDBへ接続するときに使う標準APIを答えてください。\n\n__________ 接続',
    requirements: '空欄には大文字の略称を書いてください。',
    hint: 'Spring Boot の裏側でも使われている基本技術です。',
    answer: 'JDBC',
    explanation:
      'JDBC は Java Database Connectivity の略で、Java からDBへ接続する基本APIです。',
    common_mistakes:
      'JPA は永続化の抽象化であり、DB接続APIそのものの略称ではありません。',
    display_order: 1305,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-016',
    theme_id: 'local-aws-iam',
    title: 'IAMの正式名称の末尾',
    level: 1,
    type: 'fill_blank',
    statement:
      'IAM の正式名称 Identity and Access Management の最後の単語を答えてください。\n\nIdentity and Access __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'M に対応する単語です。',
    answer: 'Management',
    explanation:
      'IAM は Identity and Access Management の略です。',
    common_mistakes:
      'Manager ではなく Management です。',
    display_order: 1401,
    themes: createAwsTheme('AWS: IAM'),
  },
  {
    id: 'local-aws-017',
    theme_id: 'local-aws-iam',
    title: 'IAMで権限の集合を表す単位',
    level: 1,
    type: 'fill_blank',
    statement:
      'IAM で許可・拒否の内容をまとめた設定単位を答えてください。\n\nIAM __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'JSONで書かれることが多いです。',
    answer: 'policy',
    explanation:
      'IAM の権限は policy として定義され、ユーザーやロールに付与されます。',
    common_mistakes:
      'group はユーザーのまとめ方であり、権限ルールそのものの名称ではありません。',
    display_order: 1402,
    themes: createAwsTheme('AWS: IAM'),
  },
  {
    id: 'local-aws-018',
    theme_id: 'local-aws-iam',
    title: 'EC2に付けるIAMの単位',
    level: 2,
    type: 'fill_blank',
    statement:
      'EC2 インスタンスに S3 参照権限を持たせたいです。\nこのとき EC2 に関連付ける IAM の単位を答えてください。\n\nIAM __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'ユーザーではなく、AWSサービスに権限を渡すときに使います。',
    answer: 'role',
    explanation:
      'EC2 などのAWSサービスに権限を渡すときは IAM role を使うのが基本です。',
    common_mistakes:
      'access key をサーバー内へ直接置くより、role を使う方が安全です。',
    display_order: 1403,
    themes: createAwsTheme('AWS: IAM'),
  },
  {
    id: 'local-aws-019',
    theme_id: 'local-aws-iam',
    title: 'ログイン主体の基本単位',
    level: 1,
    type: 'fill_blank',
    statement:
      'AWS マネジメントコンソールへ人がログインする主体としてよく作る IAM の基本単位を答えてください。\n\nIAM __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: '人に対して発行する単位です。',
    answer: 'user',
    explanation:
      '人がログインして操作する前提なら IAM user を使うことがあります。',
    common_mistakes:
      'role はサービスや一時的な権限移譲向けで、恒久的な人のアカウントとは役割が違います。',
    display_order: 1404,
    themes: createAwsTheme('AWS: IAM'),
  },
  {
    id: 'local-aws-020',
    theme_id: 'local-aws-iam',
    title: 'アクセスキーの組み合わせ',
    level: 2,
    type: 'fill_blank',
    statement:
      'プログラムから IAM ユーザーとして認証するとき、アクセスキーIDとセットで使う値を答えてください。\n\nSecret Access __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'ID と対になる秘密情報です。',
    answer: 'Key',
    explanation:
      'アクセスキーIDとSecret Access Keyを組み合わせて認証します。',
    common_mistakes:
      'Password はコンソールログイン向けであり、APIアクセス用の組み合わせとは別です。',
    display_order: 1405,
    themes: createAwsTheme('AWS: IAM'),
  },
  {
    id: 'local-aws-021',
    theme_id: 'local-aws-deploy',
    title: 'Spring BootをAWSへ出す代表構成',
    level: 1,
    type: 'fill_blank',
    statement:
      'Spring Boot アプリ本体を置く代表的な AWS サービスを答えてください。\n\nアプリ本体: __________',
    requirements: '空欄にはサービス名を書いてください。',
    hint: '仮想サーバーに jar を置いて動かす構成です。',
    answer: 'EC2',
    explanation:
      '学習初期の構成では、Spring Boot の jar を EC2 上で動かす形が分かりやすいです。',
    common_mistakes:
      'RDS はデータベース用であり、アプリ本体を動かすサービスではありません。',
    display_order: 1501,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-022',
    theme_id: 'local-aws-deploy',
    title: 'データベースを置く代表構成',
    level: 1,
    type: 'fill_blank',
    statement:
      'Spring Boot アプリのデータベースをマネージドで置く代表的な AWS サービスを答えてください。\n\nデータベース: __________',
    requirements: '空欄にはサービス名を書いてください。',
    hint: 'MySQL や PostgreSQL をマネージドで使えるサービスです。',
    answer: 'RDS',
    explanation:
      'アプリは EC2、DB は RDS という構成は初学者にも理解しやすい代表例です。',
    common_mistakes:
      'S3 はファイル保存向けであり、リレーショナルDBの置き場所ではありません。',
    display_order: 1502,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-023',
    theme_id: 'local-aws-deploy',
    title: '設定値を外へ出す管理方法',
    level: 2,
    type: 'fill_blank',
    statement:
      'DB接続情報のような環境ごとに変わる値をコードへ直書きせず管理したいです。\n空欄に入る方法名を答えてください。\n\n__________ 変数',
    requirements: '空欄には2文字の英字ではなく、日本語の一般名称を書いてください。',
    hint: 'OSや実行環境ごとに持たせられる値です。',
    answer: '環境',
    explanation:
      'DB接続情報などは環境変数で外出しするのが基本です。',
    common_mistakes:
      'application.properties に直接本番パスワードを書くと、漏えい時の影響が大きくなります。',
    display_order: 1503,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-024',
    theme_id: 'local-aws-deploy',
    title: 'アプリ疎通確認で見る先',
    level: 1,
    type: 'fill_blank',
    statement:
      'EC2 にアプリを配置したあと、まずブラウザで確認しやすいアクセス先を答えてください。\n\nhttp://<EC2の__________>',
    requirements: '空欄には日本語1語を書いてください。',
    hint: 'DNS未設定でも試しやすい確認先です。',
    answer: '公開IP',
    explanation:
      'デプロイ直後の疎通確認では、まず EC2 の公開IP へアクセスするのが分かりやすいです。',
    common_mistakes:
      'プライベートIP はVPC内向けなので、手元のブラウザからは直接届きません。',
    display_order: 1504,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-025',
    theme_id: 'local-aws-deploy',
    title: 'アプリログを追うLinuxコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      'app.log の末尾を追いかけながらログ確認したいです。\n空欄に入るコマンド全体を答えてください。\n\n__________',
    requirements: 'Linuxでログ末尾を追う基本コマンドを書いてください。',
    hint: 'リアルタイム監視でよく使うコマンドです。',
    answer: 'tail -f app.log',
    explanation:
      'tail -f を使うと、ログの末尾を追いかけながらアプリの挙動を確認できます。',
    common_mistakes:
      'cat だと一度表示するだけで追従できません。',
    display_order: 1505,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-026',
    theme_id: 'local-aws-deploy',
    title: 'HTTPS公開で代表的に使うポート',
    level: 1,
    type: 'fill_blank',
    statement:
      'HTTPS で外部公開するとき、セキュリティグループで許可する代表的なポート番号を答えてください。\n\nポート __________',
    requirements: '空欄には数字だけを書いてください。',
    hint: 'http ではなく https の標準ポートです。',
    answer: '443',
    explanation:
      'HTTPS の標準ポートは 443 です。',
    common_mistakes:
      '80 は HTTP 用なので、HTTPS と混同しないようにします。',
    display_order: 1506,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-027',
    theme_id: 'local-aws-deploy',
    title: '障害切り分けでまず見るAWS設定',
    level: 2,
    type: 'fill_blank',
    statement:
      'ブラウザからEC2へアクセスできないとき、まず確認したいネットワーク設定を答えてください。\n\nSecurity __________',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'ポート開放の確認で最優先です。',
    answer: 'Group',
    explanation:
      '外からアクセスできないときは、まず Security Group の受信ルールを確認するのが基本です。',
    common_mistakes:
      'IAM 権限だけを見ても、ネットワーク疎通の問題は解決しません。',
    display_order: 1507,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-028',
    theme_id: 'local-aws-deploy',
    title: 'JAR配置でよく使う転送手段',
    level: 2,
    type: 'fill_blank',
    statement:
      'ローカルの task-app.jar を EC2 にコピーするとき、SSH系でよく使う転送コマンドの略称を答えてください。\n\n__________ 転送',
    requirements: '空欄には大文字の略称を書いてください。',
    hint: 'SSH の仲間として使われます。',
    answer: 'SCP',
    explanation:
      'SCP を使うと、ローカルファイルを EC2 へ安全にコピーできます。',
    common_mistakes:
      'FTP はクラウド学習の最初のEC2転送手段としてはあまり代表的ではありません。',
    display_order: 1508,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-029',
    theme_id: 'local-aws-deploy',
    title: 'Spring Bootの実行ユーザーで避けたいこと',
    level: 3,
    type: 'fill_blank',
    statement:
      '本番構成では、権限を持ちすぎた root でアプリを常時動かすのは避けたいです。\n空欄に入るユーザー名を答えてください。\n\n避けたい実行ユーザー: __________',
    requirements: '空欄には英字1語を書いてください。',
    hint: 'Linuxで最上位権限を持つユーザーです。',
    answer: 'root',
    explanation:
      '本番では root 常用を避け、必要最小限の権限でアプリを動かす方が安全です。',
    common_mistakes:
      'すぐ動くからといって root で全部済ませると、事故時の影響が大きくなります。',
    display_order: 1509,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-030',
    theme_id: 'local-aws-deploy',
    title: 'アーキテクチャ全体の基本形',
    level: 3,
    type: 'fill_blank',
    statement:
      'Spring Boot 学習用の代表的な AWS 構成を「アプリ本体 + DB」の形で答えてください。\n\n__________ + __________',
    requirements: '左にアプリ本体、右にDBサービスを書いてください。',
    hint: '一番基本の2サービス構成です。',
    answer: 'EC2 + RDS',
    explanation:
      'EC2 + RDS は、Spring Boot の学習で全体像を理解しやすい基本構成です。',
    common_mistakes:
      'S3 は静的ファイル保存に向いていますが、この2層の基本構成のDB枠には入りません。',
    display_order: 1510,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-031',
    theme_id: 'local-aws-ec2',
    title: 'EC2で8080番ポートを公開する設定を書く',
    level: 2,
    type: 'normal',
    statement:
      'Spring Boot アプリを EC2 上で 8080 番ポートで公開したいです。セキュリティグループで追加するインバウンドルールを1つ書いてください。',
    requirements:
      'TCP を指定すること\nポート番号 8080 を指定すること\n公開元は学習用なので 0.0.0.0/0 と書いてよいこと',
    hint: 'HTTP の 80 番ではなく、Spring Boot をそのまま起動したときの典型ポートを開ける問題です。',
    answer:
      'Type: Custom TCP\nPort range: 8080\nSource: 0.0.0.0/0',
    explanation:
      'EC2 に直接 Spring Boot を載せる構成では、まずアプリが待ち受けているポートをセキュリティグループで開ける必要があります。',
    common_mistakes:
      '22 を開けるのは SSH 用で、ブラウザからアプリへアクセスするための設定とは別です。',
    display_order: 1511,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-032',
    theme_id: 'local-aws-rds',
    title: 'RDS接続用のapplication.propertiesを書く',
    level: 3,
    type: 'normal',
    statement:
      'Spring Boot から RDS(MySQL) に接続するための `application.properties` を3行だけ書いてください。ホスト名は `sample-db.ap-northeast-1.rds.amazonaws.com`、DB名は `task_app`、ユーザー名は `appuser`、パスワードは `secret123` とします。',
    requirements:
      '`spring.datasource.url` を書くこと\n`spring.datasource.username` を書くこと\n`spring.datasource.password` を書くこと',
    hint: 'JDBC URL は `jdbc:mysql://ホスト名:3306/DB名` の形です。',
    answer:
      'spring.datasource.url=jdbc:mysql://sample-db.ap-northeast-1.rds.amazonaws.com:3306/task_app\nspring.datasource.username=appuser\nspring.datasource.password=secret123',
    explanation:
      'RDS 接続では URL・ユーザー名・パスワードの3点が最低限必要です。初学者のうちはまずこの形を確実に書けるのが大事です。',
    common_mistakes:
      'URL に `http://` を書くと Web URL になってしまい、JDBC 接続文字列としては誤りです。',
    display_order: 1512,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-033',
    theme_id: 'local-aws-s3',
    title: 'S3で静的サイトを公開する最小手順を書く',
    level: 2,
    type: 'normal',
    statement:
      'HTML ファイルを S3 で静的公開したいです。最小手順を3つ、短く書いてください。',
    requirements:
      'バケット作成を書くこと\nStatic Website Hosting を有効化すること\n`index.html` をアップロードすること',
    hint: 'CloudFront や Route 53 はまだ不要です。S3 単体で公開する最初の形を答えます。',
    answer:
      '1. S3 バケットを作成する\n2. Static Website Hosting を有効にする\n3. index.html をアップロードする',
    explanation:
      'S3 の静的公開は、まず単体で動く最小構成を理解するとあとで CloudFront へ広げやすくなります。',
    common_mistakes:
      'EC2 を立てる必要はありません。S3 単体で静的ファイルを公開できます。',
    display_order: 1513,
    themes: createAwsTheme('AWS: S3'),
  },
  {
    id: 'local-aws-034',
    theme_id: 'local-aws-iam',
    title: 'EC2にS3読み取り権限を持たせるIAM設定を書く',
    level: 3,
    type: 'normal',
    statement:
      'EC2 上のアプリから S3 のファイルを読み取りたいです。アクセスキーを直接アプリに埋め込まずに実現したいとき、IAM でどう設定するか短く書いてください。',
    requirements:
      'IAM ロールを使うこと\nS3 読み取り権限の policy を付けること\nそのロールを EC2 に関連付けること',
    hint: '学習用でもアクセスキー直書きより、ロールを使う構成を覚えておく方が安全です。',
    answer:
      '1. S3 読み取り権限を持つ IAM ロールを作成する\n2. そのロールに policy を付与する\n3. 作成したロールを EC2 インスタンスに関連付ける',
    explanation:
      'EC2 から AWS サービスへアクセスするときは、アクセスキーを置くより IAM ロールを関連付ける構成が基本です。',
    common_mistakes:
      'IAM user のアクセスキーを `application.properties` に書く運用は、初学者でも早めに避けた方がよいです。',
    display_order: 1514,
    themes: createAwsTheme('AWS: IAM'),
  },
  {
    id: 'local-aws-035',
    theme_id: 'local-aws-deploy',
    title: 'Spring BootをAWSへ配置する基本構成を説明する',
    level: 2,
    type: 'normal',
    statement:
      'Spring Boot アプリ、DB、画像ファイル保存先を AWS で分けて置きたいです。どのサービスに置くかを1行ずつ書いてください。',
    requirements:
      'Spring Boot アプリの配置先を書くこと\nDB の配置先を書くこと\n画像ファイル保存先を書くこと',
    hint: '学習用の基本構成は、アプリ・DB・ファイル保存を役割ごとに分けます。',
    answer:
      'アプリ本体: EC2\nデータベース: RDS\n画像ファイル保存: S3',
    explanation:
      '役割ごとに AWS サービスを分けて考えると、構成の理解がかなり整理されます。',
    common_mistakes:
      'S3 はファイル保存向けで、リレーショナル DB の代わりにはなりません。',
    display_order: 1515,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-036',
    theme_id: 'local-aws-ec2',
    title: 'EC2でSpring Bootをバックグラウンド起動するコマンドを書く',
    level: 3,
    type: 'normal',
    statement:
      '`task-app.jar` を EC2 上で SSH 切断後も動き続けるように起動したいです。よく使う Linux コマンドを1行で書いてください。',
    requirements:
      '`nohup` を使うこと\n`java -jar task-app.jar` を含めること\nログ出力先を書くこと',
    hint: '`&` を付けてバックグラウンド起動にします。',
    answer:
      'nohup java -jar task-app.jar > app.log 2>&1 &',
    explanation:
      '学習用の単純構成では `nohup` でバックグラウンド起動する形をまず覚えると運用確認がしやすくなります。',
    common_mistakes:
      '`java -jar task-app.jar` だけだと SSH セッション終了で停止しやすく、確認にも向きません。',
    display_order: 1516,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-037',
    theme_id: 'local-aws-ec2',
    title: 'SSH接続がタイムアウトするときの確認点を書く',
    level: 2,
    type: 'normal',
    statement:
      'EC2 に SSH 接続しようとするとタイムアウトします。最初に確認したいポイントを2つ書いてください。',
    requirements:
      'セキュリティグループで 22 番ポートが開いているかを書くこと\n正しいキーペアを使っているか、または接続先IPが合っているかのどちらかを書くこと',
    hint: '初学者が最初に詰まりやすいのは、ネットワーク設定と接続情報のミスです。',
    answer:
      '1. セキュリティグループで SSH 用の 22 番ポートが開いているか確認する\n2. 接続先の公開 IP と使用しているキーペアが正しいか確認する',
    explanation:
      'SSH タイムアウトは、アプリの問題より先にネットワーク到達性や接続情報の確認が重要です。',
    common_mistakes:
      'IAM 権限だけを見ても SSH タイムアウトは解決しません。まずはネットワークです。',
    display_order: 1517,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-038',
    theme_id: 'local-aws-rds',
    title: 'EC2からRDSへつながらないときの確認点を書く',
    level: 3,
    type: 'normal',
    statement:
      'EC2 上の Spring Boot から RDS へ接続できません。最初に確認したいポイントを2つ書いてください。',
    requirements:
      'RDS 側のセキュリティグループ設定を書くこと\n`spring.datasource.url` など接続情報の確認を書くこと',
    hint: 'DB 接続エラーは、ネットワーク設定と接続文字列の両方を見るのが基本です。',
    answer:
      '1. RDS のセキュリティグループで EC2 からの接続が許可されているか確認する\n2. `spring.datasource.url`、ユーザー名、パスワードが正しいか確認する',
    explanation:
      'RDS 接続トラブルは、設定ファイルだけ見ても不足で、セキュリティグループも必ず確認します。',
    common_mistakes:
      'IAM policy は RDS への JDBC 接続可否とは直接別物なので、最初の確認点としては優先度が下がります。',
    display_order: 1518,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-039',
    theme_id: 'local-aws-iam',
    title: 'S3読み取りだけを許可するpolicyの要点を書く',
    level: 3,
    type: 'normal',
    statement:
      '特定バケットのファイルを読むだけ許可したいです。IAM policy の要点を2つ短く書いてください。',
    requirements:
      'Action に `s3:GetObject` を入れること\nResource に対象バケット配下を指定すること',
    hint: '学習用なので JSON 全文ではなく、どこをどう書くかがわかれば大丈夫です。',
    answer:
      'Action: s3:GetObject\nResource: arn:aws:s3:::sample-bucket/*',
    explanation:
      'IAM policy は「何を(Action)」「どこへ(Resource)」の組み合わせで考えると整理しやすいです。',
    common_mistakes:
      '`s3:*` のように広く許可しすぎると、学習初期でも最小権限の考え方が身につきにくくなります。',
    display_order: 1519,
    themes: createAwsTheme('AWS: IAM'),
  },
  {
    id: 'local-aws-040',
    theme_id: 'local-aws-deploy',
    title: 'デプロイ直後に確認する項目を書く',
    level: 2,
    type: 'normal',
    statement:
      'Spring Boot アプリを EC2 へデプロイした直後に、最低限確認したい項目を3つ書いてください。',
    requirements:
      'URL へアクセスして画面または API 応答を確認すること\nアプリログを確認すること\nDB 接続または主要機能を1つ動かして確認すること',
    hint: '「起動したはず」で終わらせず、見える確認を入れるのが大事です。',
    answer:
      '1. ブラウザや API クライアントで URL にアクセスして応答を確認する\n2. `tail -f app.log` などでアプリログを確認する\n3. DB を使う機能を1つ実行して接続できているか確認する',
    explanation:
      'デプロイ確認は、起動確認だけでなく、通信・ログ・DB の3点を見ると不具合の見落としが減ります。',
    common_mistakes:
      '画面が開いたことだけで成功判定すると、DB エラーや一部機能の不具合を見逃しやすいです。',
    display_order: 1520,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-041',
    theme_id: 'local-aws-deploy',
    title: 'JAR配備から起動確認までの手順を書く',
    level: 3,
    type: 'normal',
    statement:
      'ローカルで作った `task-app.jar` を EC2 へ配置し、起動してログ確認するまでの流れを4手順で書いてください。',
    requirements:
      '`scp` でファイル転送すること\n`ssh` で接続すること\n`nohup java -jar ...` で起動すること\n`tail -f app.log` でログ確認すること',
    hint: '研修では「画面を作る」だけでなく、サーバへ持っていって動かす流れもよく確認されます。',
    answer:
      '1. `scp task-app.jar ec2-user@<public-ip>:/home/ec2-user/` で JAR を転送する\n2. `ssh ec2-user@<public-ip>` で EC2 へ接続する\n3. `nohup java -jar task-app.jar > app.log 2>&1 &` で起動する\n4. `tail -f app.log` で起動ログを確認する',
    explanation:
      'デプロイの最小手順を言語化できると、研修での手順抜けや詰まりをかなり減らせます。',
    common_mistakes:
      'JAR を転送しただけで完了と考えると、起動確認とログ確認が抜けやすくなります。',
    display_order: 1521,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
  {
    id: 'local-aws-042',
    theme_id: 'local-aws-ec2',
    title: 'EC2上のアプリへブラウザ接続できないときの確認点を書く',
    level: 3,
    type: 'normal',
    statement:
      'Spring Boot を EC2 で起動したのに、ブラウザから `http://<public-ip>:8080` へアクセスできません。最初に確認したいポイントを3つ書いてください。',
    requirements:
      'アプリが起動しているか、またはログ確認を書くこと\n8080 ポートのセキュリティグループ確認を書くこと\n公開 IP や URL が正しいか確認を書くこと',
    hint: '「アプリ」「ネットワーク」「アクセス先」の3つへ分けて見ると整理しやすいです。',
    answer:
      '1. `app.log` やプロセス確認で Spring Boot が実際に起動しているか確認する\n2. セキュリティグループで 8080 ポートが許可されているか確認する\n3. ブラウザでアクセスしている公開 IP とポート番号が正しいか確認する',
    explanation:
      'AWS の接続不具合は、アプリ本体・ネットワーク・URL のどこで止まっているかを切り分けるのが基本です。',
    common_mistakes:
      'いきなり IAM 権限だけを見ると、本当に多い原因であるポート未開放や URL ミスを見逃しやすくなります。',
    display_order: 1522,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-043',
    theme_id: 'local-aws-rds',
    title: 'RDS接続失敗の切り分け手順を書く',
    level: 3,
    type: 'normal',
    statement:
      'EC2 上の Spring Boot から RDS へ接続するとエラーになります。最初に確認したいポイントを3つ書いてください。',
    requirements:
      'RDS 側のセキュリティグループ確認を書くこと\n`spring.datasource.url` など接続情報確認を書くこと\nRDS のエンドポイントや DB 状態確認を書くこと',
    hint: 'DB 接続では「接続情報」「到達性」「DB 側の状態」の3つを見ると精度が上がります。',
    answer:
      '1. RDS のセキュリティグループで EC2 からの接続が許可されているか確認する\n2. `spring.datasource.url`、ユーザー名、パスワードが正しいか確認する\n3. RDS のエンドポイント名と DB インスタンスの状態が正しいか確認する',
    explanation:
      'RDS 接続エラーは、設定ファイルだけではなくネットワーク許可と DB 自体の状態確認までセットで行うのが実践的です。',
    common_mistakes:
      'コードだけを見続けると、実際にはセキュリティグループや接続先ホスト名のミスだった、という定番パターンを逃しやすいです。',
    display_order: 1523,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-044',
    theme_id: 'local-aws-ec2',
    title: 'EC2 上のアプリにブラウザ接続できないバグを切り分ける',
    level: 3,
    type: 'normal',
    statement:
      'Spring Boot アプリを EC2 に配置して起動できたつもりですが、`http://<public-ip>:8080` へアクセスしてもブラウザがタイムアウトします。まず確認するポイントを 3 つ書いてください。',
    requirements:
      'アプリ自体の起動確認を 1 つ書くこと\nセキュリティグループを 1 つ書くこと\nURL や接続先の確認を 1 つ書くこと',
    hint: '「アプリが動いているか」「ポートが開いているか」「見に行く先が正しいか」の 3 つに分けると整理しやすいです。',
    answer:
      '1. `java -jar` のログや `app.log` を見て、Spring Boot が正常起動しているか確認する。\n2. EC2 のセキュリティグループで 8080 番ポートが許可されているか確認する。\n3. ブラウザでアクセスしている公開 IP とポート番号が正しいか確認する。',
    explanation:
      'EC2 上の接続トラブルは、アプリ未起動・ポート未開放・接続先間違いの 3 パターンが特に多いです。',
    common_mistakes:
      'いきなり IAM 権限だけを疑うのは遠回りです。まずはブラウザ接続に直結するネットワークと起動状態から確認します。',
    display_order: 1524,
    themes: createAwsTheme('AWS: EC2'),
  },
  {
    id: 'local-aws-045',
    theme_id: 'local-aws-rds',
    title: 'RDS に接続できないときの設定ミスを切り分ける',
    level: 3,
    type: 'normal',
    statement:
      'EC2 上の Spring Boot アプリから RDS に接続しようとするとエラーになります。設定ミスとして最初に確認したいポイントを 3 つ書いてください。',
    requirements:
      'セキュリティグループの確認を含めること\nJDBC URL の確認を含めること\nユーザー名・パスワードまたは DB 名の確認を含めること',
    hint: 'DB 接続は「ネットワーク」「接続文字列」「認証情報」に分けて考えると原因を追いやすいです。',
    answer:
      '1. RDS 側のセキュリティグループで、EC2 からの接続が許可されているか確認する。\n2. `spring.datasource.url` のホスト名・ポート・DB 名が正しいか確認する。\n3. `spring.datasource.username` と `spring.datasource.password` が正しいか確認する。',
    explanation:
      'RDS 接続失敗はコードそのものより、接続先の設定やネットワーク許可のずれで起きることが多いです。',
    common_mistakes:
      'JAR を再配置する前に、まず接続設定の基本 3 点を見た方が早いです。コードだけ見ていると原因を見落としやすくなります。',
    display_order: 1525,
    themes: createAwsTheme('AWS: RDS'),
  },
  {
    id: 'local-aws-046',
    theme_id: 'local-aws-deploy',
    title: '古い JAR を起動していて修正が反映されないバグを見抜く',
    level: 3,
    type: 'normal',
    statement:
      'コードを直して JAR をアップロードしたつもりなのに、EC2 で動かすと古い挙動のままです。原因確認として行う操作を 3 つ書いてください。',
    requirements:
      '新しい JAR が配置されたか確認すること\n起動中プロセスの確認を含めること\n再起動またはログ確認の観点を含めること',
    hint: 'デプロイでは「ファイルが置き換わったか」「古いプロセスが残っていないか」「新しい起動が成功したか」を見ると整理できます。',
    answer:
      '1. EC2 上で JAR の配置先と更新日時を確認して、新しいファイルが置かれているか確かめる。\n2. `ps` などで古い Java プロセスが残っていないか確認する。\n3. 新しい JAR を起動し直し、ログを見て想定したバージョンのアプリが起動しているか確認する。',
    explanation:
      'デプロイ後に修正が反映されないときは、コードよりも「古い成果物」「古いプロセス」「起動失敗」のどれかであることが多いです。',
    common_mistakes:
      'アップロードしたつもりでも別ディレクトリに置いていることがあります。まず配置先と実際に動いているプロセスを対応付けて確認します。',
    display_order: 1526,
    themes: createAwsTheme('AWS: デプロイ構成'),
  },
]

export const LOCAL_FLUTTER_PROBLEMS: ProblemRecord[] = [
  {
    id: 'local-flutter-001',
    theme_id: 'local-flutter-widget-basic',
    title: '画面を持たない基本Widget',
    level: 1,
    type: 'fill_blank',
    statement:
      '状態を持たない画面部品を作る基本クラス名を答えてください。\n\n__________',
    requirements: '空欄にはクラス名だけを書いてください。',
    hint: 'StatefulWidget と対になる基本Widgetです。',
    answer: 'StatelessWidget',
    explanation:
      '状態を持たないUI部品は StatelessWidget を継承して作るのが基本です。',
    common_mistakes:
      'StatefulWidget は状態を持つ前提のときに使うので、役割が違います。',
    display_order: 2101,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-002',
    theme_id: 'local-flutter-widget-basic',
    title: '状態を持つ基本Widget',
    level: 1,
    type: 'fill_blank',
    statement:
      '状態を持つ画面部品を作る基本クラス名を答えてください。\n\n__________',
    requirements: '空欄にはクラス名だけを書いてください。',
    hint: 'StatelessWidget と対になるもう一方です。',
    answer: 'StatefulWidget',
    explanation:
      '画面内で値が変わる場合は StatefulWidget を継承して作るのが基本です。',
    common_mistakes:
      '状態が変わるのに StatelessWidget を選ぶと、更新ロジックを自然に書きにくくなります。',
    display_order: 2102,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-003',
    theme_id: 'local-flutter-widget-basic',
    title: 'Widgetを返す基本メソッド',
    level: 1,
    type: 'fill_blank',
    statement:
      'Flutter でUIを組み立てる基本メソッド名を答えてください。\n\n__________ メソッド',
    requirements: '空欄には1語だけを書いてください。',
    hint: 'BuildContext を引数に受け取ることが多いです。',
    answer: 'build',
    explanation:
      'build メソッドの中でWidgetツリーを返して画面を構築します。',
    common_mistakes:
      'render のような名前ではなく、Flutter では build が基本です。',
    display_order: 2103,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-004',
    theme_id: 'local-flutter-widget-basic',
    title: '文字を表示するWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      '「Hello」を画面に表示する基本Widget名を答えてください。\n\n__________("Hello")',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: '最も基本的な表示用Widgetです。',
    answer: 'Text',
    explanation:
      '文字列を画面に表示するときは Text Widget を使います。',
    common_mistakes:
      'Label ではなく Text がFlutterの基本Widget名です。',
    display_order: 2104,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-005',
    theme_id: 'local-flutter-widget-basic',
    title: '箱として使う基本Widget',
    level: 1,
    type: 'fill_blank',
    statement:
      '余白や背景色を付けた箱として使いやすい基本Widget名を答えてください。\n\n__________',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: '大きさや色も設定しやすいWidgetです。',
    answer: 'Container',
    explanation:
      'Container は余白・色・サイズなどをまとめて扱いやすい基本Widgetです。',
    common_mistakes:
      'Box という名前の基本Widgetはありません。',
    display_order: 2105,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-006',
    theme_id: 'local-flutter-widget-basic',
    title: '縦方向に並べるWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      '子Widgetを縦方向に並べる基本Widget名を答えてください。\n\n__________',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: '横並びの Row と対になるWidgetです。',
    answer: 'Column',
    explanation:
      '複数のWidgetを縦方向へ並べたいときは Column を使います。',
    common_mistakes:
      '縦並びなのに Row を使うと、レイアウト方向が逆になります。',
    display_order: 2106,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-007',
    theme_id: 'local-flutter-widget-basic',
    title: '横方向に並べるWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      '子Widgetを横方向に並べる基本Widget名を答えてください。\n\n__________',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: '縦並びの Column と対になるWidgetです。',
    answer: 'Row',
    explanation:
      '複数のWidgetを横方向へ並べるときは Row を使います。',
    common_mistakes:
      'Column と混同しやすいですが、Row は横方向です。',
    display_order: 2107,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-008',
    theme_id: 'local-flutter-widget-basic',
    title: '基本画面の土台となるWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      'AppBar や body をまとめて持てる基本画面Widget名を答えてください。\n\n__________',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'Material Design ベースの画面土台です。',
    answer: 'Scaffold',
    explanation:
      'Scaffold は AppBar や body など、基本画面の骨組みを提供します。',
    common_mistakes:
      'Screen ではなく Scaffold がFlutterの標準的な画面土台です。',
    display_order: 2108,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-009',
    theme_id: 'local-flutter-layout',
    title: '外側の余白を付けるWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      '子Widgetの周りに余白を付ける基本Widget名を答えてください。\n\n__________(padding: EdgeInsets.all(16), child: Text("A"))',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'padding プロパティを持つ代表的Widgetです。',
    answer: 'Padding',
    explanation:
      'Padding を使うと、子Widgetの周りに余白を付けられます。',
    common_mistakes:
      'Margin というWidget名ではありません。',
    display_order: 2201,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-010',
    theme_id: 'local-flutter-layout',
    title: '残り領域を広げて使うWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      'Row や Column の中で、残り領域を広げて使う基本Widget名を答えてください。\n\n__________(child: Container())',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'flex を持たせると比率も調整できます。',
    answer: 'Expanded',
    explanation:
      'Expanded は残っているスペースを広げて使いたいときの基本Widgetです。',
    common_mistakes:
      'Center は中央寄せ用で、残り領域を分配する目的とは違います。',
    display_order: 2202,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-011',
    theme_id: 'local-flutter-layout',
    title: '柔軟に広がるWidget',
    level: 2,
    type: 'fill_blank',
    statement:
      'Expanded より柔らかくレイアウトさせたいときに使うWidget名を答えてください。\n\n__________(child: Text("A"))',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'Expanded と同じく Flex 系で使います。',
    answer: 'Flexible',
    explanation:
      'Flexible は、必要に応じて広がる柔軟なレイアウトを作るときに使います。',
    common_mistakes:
      'Expanded と役割が近いですが、挙動が少し違います。',
    display_order: 2203,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-012',
    theme_id: 'local-flutter-layout',
    title: '縦スクロール一覧を作るWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      '縦にスクロールするリスト表示を作る基本Widget名を答えてください。\n\n__________',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'builder コンストラクタもよく使います。',
    answer: 'ListView',
    explanation:
      '縦スクロールの一覧を作る基本は ListView です。',
    common_mistakes:
      'Column はスクロールしないので、要素数が増える一覧には向きません。',
    display_order: 2204,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-013',
    theme_id: 'local-flutter-layout',
    title: '格子状表示を作るWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      'カードを格子状に並べるときによく使うWidget名を答えてください。\n\n__________',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: '2列や3列で並べるUIに向いています。',
    answer: 'GridView',
    explanation:
      'GridView は格子状レイアウトに向いたスクロールWidgetです。',
    common_mistakes:
      'ListView は1方向のリスト表示なので、格子状には向きません。',
    display_order: 2205,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-014',
    theme_id: 'local-flutter-layout',
    title: '子Widgetを中央寄せするWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      '子Widgetを中央に寄せる最も基本的なWidget名を答えてください。\n\n__________(child: Text("Hello"))',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: '1つの子Widgetを真ん中へ置きたい場面です。',
    answer: 'Center',
    explanation:
      'Center は子Widgetを中央寄せするためのシンプルなWidgetです。',
    common_mistakes:
      'Align でも位置調整できますが、中央固定なら Center の方が素直です。',
    display_order: 2206,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-015',
    theme_id: 'local-flutter-layout',
    title: '位置を細かく寄せるWidget',
    level: 2,
    type: 'fill_blank',
    statement:
      '子Widgetを左上や右下など、細かい位置へ寄せる基本Widget名を答えてください。\n\n__________(alignment: Alignment.topLeft, child: Text("A"))',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'alignment プロパティで位置指定します。',
    answer: 'Align',
    explanation:
      'Align は alignment を使って子Widgetの位置を細かく調整できます。',
    common_mistakes:
      'Center は中央寄せ専用で、左上や右下を直接指定できません。',
    display_order: 2207,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-016',
    theme_id: 'local-flutter-layout',
    title: 'スクロールさせる基本方向',
    level: 2,
    type: 'fill_blank',
    statement:
      'ListView の既定スクロール方向を答えてください。\n\nAxis.__________',
    requirements: '空欄には列挙子名だけを書いてください。',
    hint: '普通の ListView は上下に動きます。',
    answer: 'vertical',
    explanation:
      'ListView の既定方向は Axis.vertical です。',
    common_mistakes:
      '横スクロールにしたい場合は horizontal を明示的に指定します。',
    display_order: 2208,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-017',
    theme_id: 'local-flutter-state',
    title: 'StatefulWidgetで状態更新するメソッド',
    level: 1,
    type: 'fill_blank',
    statement:
      'StatefulWidget で画面を再描画させる基本メソッド名を答えてください。\n\n__________(() {\n  counter++;\n});',
    requirements: '空欄にはメソッド名だけを書いてください。',
    hint: '状態更新と再描画をまとめて知らせます。',
    answer: 'setState',
    explanation:
      'setState を呼ぶと、状態変更後に build が再実行されます。',
    common_mistakes:
      '変数だけ変えても、setState を呼ばないと画面が更新されないことがあります。',
    display_order: 2301,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-018',
    theme_id: 'local-flutter-state',
    title: 'カウンターを1増やす式',
    level: 1,
    type: 'fill_blank',
    statement:
      'counter を 1 増やしたいです。\n空欄に入る1行だけを答えてください。\n\nsetState(() {\n  __________\n});',
    requirements: '空欄には1行だけを書いてください。',
    hint: 'インクリメント演算子を使えます。',
    answer: 'counter++;',
    explanation:
      'setState の中で状態変数を更新すると、画面にも反映されます。',
    common_mistakes:
      'counter + 1; だけでは代入されないので値は変わりません。',
    display_order: 2302,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-019',
    theme_id: 'local-flutter-state',
    title: 'TextFieldの入力値を受け取る引数名',
    level: 1,
    type: 'fill_blank',
    statement:
      'TextField で入力値の変化を受け取りたいです。\n空欄に入るプロパティ名を答えてください。\n\nTextField(\n  __________: (value) {\n    text = value;\n  },\n)',
    requirements: '空欄にはプロパティ名だけを書いてください。',
    hint: '入力中の値変化を受け取るコールバックです。',
    answer: 'onChanged',
    explanation:
      'onChanged を使うと、入力中の文字列変化をそのまま受け取れます。',
    common_mistakes:
      'onTap はタップ時イベントであり、入力値の変化通知ではありません。',
    display_order: 2303,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-020',
    theme_id: 'local-flutter-state',
    title: '入力値を保持するクラス',
    level: 2,
    type: 'fill_blank',
    statement:
      'TextField の値をコントローラで管理したいです。\n空欄に入るクラス名を答えてください。\n\nfinal controller = __________();',
    requirements: '空欄にはクラス名だけを書いてください。',
    hint: 'text プロパティを持つ入力制御クラスです。',
    answer: 'TextEditingController',
    explanation:
      'TextEditingController を使うと、TextField の現在値を取得・更新しやすくなります。',
    common_mistakes:
      'TextController という基本クラス名はありません。',
    display_order: 2304,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-021',
    theme_id: 'local-flutter-state',
    title: '初期値を0へ戻す式',
    level: 1,
    type: 'fill_blank',
    statement:
      'counter を 0 に戻したいです。\n空欄に入る1行だけを答えてください。\n\nsetState(() {\n  __________\n});',
    requirements: '空欄には1行だけを書いてください。',
    hint: '再代入すれば初期化できます。',
    answer: 'counter = 0;',
    explanation:
      'setState の中で 0 を代入すると、画面上の値もリセットされます。',
    common_mistakes:
      'counter == 0; は比較であり、代入ではありません。',
    display_order: 2305,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-022',
    theme_id: 'local-flutter-state',
    title: 'bool状態を切り替える式',
    level: 2,
    type: 'fill_blank',
    statement:
      'isLoading の true / false を切り替えたいです。\n空欄に入る1行だけを答えてください。\n\nsetState(() {\n  __________\n});',
    requirements: '空欄には1行だけを書いてください。',
    hint: '否定演算子を使います。',
    answer: 'isLoading = !isLoading;',
    explanation:
      '! を使うと bool 値を反転できます。',
    common_mistakes:
      'isLoading != isLoading; は代入ではないので状態更新になりません。',
    display_order: 2306,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-023',
    theme_id: 'local-flutter-state',
    title: 'StatefulWidgetのState型宣言',
    level: 2,
    type: 'fill_blank',
    statement:
      'CounterPage の State クラス宣言を書きたいです。\n空欄に入る継承先だけを答えてください。\n\nclass _CounterPageState extends __________ {\n}',
    requirements: '空欄には型名だけを書いてください。',
    hint: '対応するWidgetクラスを型引数に取ります。',
    answer: 'State<CounterPage>',
    explanation:
      'State クラスは State<対応するWidget> を継承して作ります。',
    common_mistakes:
      'StatefulWidget を直接継承するのは State クラスの役割と違います。',
    display_order: 2307,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-024',
    theme_id: 'local-flutter-state',
    title: 'フォーム入力を取得する式',
    level: 2,
    type: 'fill_blank',
    statement:
      'controller から現在の入力文字列を取り出したいです。\n空欄に入る式だけを答えてください。\n\nfinal text = __________;',
    requirements: '空欄には式だけを書いてください。',
    hint: 'controller の text プロパティです。',
    answer: 'controller.text',
    explanation:
      'TextEditingController の text で現在値を取得できます。',
    common_mistakes:
      'controller.value だけでは文字列そのものではありません。',
    display_order: 2308,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-025',
    theme_id: 'local-flutter-state',
    title: 'ロジックを分ける基本単位',
    level: 3,
    type: 'fill_blank',
    statement:
      '表示とは別の責務として、値計算や保存処理を分けるときの基本単位を答えてください。\n\n__________ 分離',
    requirements: '空欄には日本語1語を書いてください。',
    hint: 'UIと対になる役割を意識します。',
    answer: 'ロジック',
    explanation:
      '状態管理では、UI とロジックの責務を分ける発想が大切です。',
    common_mistakes:
      '全部を build メソッドに詰め込むと、後から読みにくくなります。',
    display_order: 2309,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-026',
    theme_id: 'local-flutter-state',
    title: '状態を初期化するライフサイクル',
    level: 3,
    type: 'fill_blank',
    statement:
      'State クラスで初期化処理を書く代表的なメソッド名を答えてください。\n\n@override\nvoid __________() {\n  super.initState();\n}',
    requirements: '空欄にはメソッド名だけを書いてください。',
    hint: 'build の前に1回呼ばれます。',
    answer: 'initState',
    explanation:
      'initState は State が最初に作られたタイミングで1回だけ呼ばれる初期化用メソッドです。',
    common_mistakes:
      'initialize という名前の標準メソッドはありません。',
    display_order: 2310,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-027',
    theme_id: 'local-flutter-navigation',
    title: '次の画面へ進むメソッド',
    level: 1,
    type: 'fill_blank',
    statement:
      '新しい画面へ遷移するときによく使うメソッド名を答えてください。\n\nNavigator.__________(context, route)',
    requirements: '空欄にはメソッド名だけを書いてください。',
    hint: '戻る操作の pop と対になるメソッドです。',
    answer: 'push',
    explanation:
      '新しい画面をスタックへ積んで遷移するときは Navigator.push を使います。',
    common_mistakes:
      'pop は戻る処理なので、進む操作とは逆です。',
    display_order: 2401,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-028',
    theme_id: 'local-flutter-navigation',
    title: '前の画面へ戻るメソッド',
    level: 1,
    type: 'fill_blank',
    statement:
      '現在の画面を閉じて前の画面へ戻るメソッド名を答えてください。\n\nNavigator.__________(context);',
    requirements: '空欄にはメソッド名だけを書いてください。',
    hint: 'push の逆です。',
    answer: 'pop',
    explanation:
      'Navigator.pop を使うと、現在の画面を閉じて前の画面へ戻れます。',
    common_mistakes:
      'back という標準メソッド名ではありません。',
    display_order: 2402,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-029',
    theme_id: 'local-flutter-navigation',
    title: '画面をMaterialPageRouteで包む',
    level: 1,
    type: 'fill_blank',
    statement:
      'NextPage へ遷移するための route を作りたいです。\n空欄に入る return の右辺だけを答えてください。\n\nNavigator.push(\n  context,\n  MaterialPageRoute(\n    builder: (context) {\n      return __________;\n    },\n  ),\n);',
    requirements: '空欄には返すWidgetだけを書いてください。',
    hint: '遷移先の画面Widgetを生成します。',
    answer: 'NextPage()',
    explanation:
      'MaterialPageRoute の builder では、遷移先の画面Widgetを返します。',
    common_mistakes:
      'context を返すのではなく、画面Widgetそのものを返す必要があります。',
    display_order: 2403,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-030',
    theme_id: 'local-flutter-navigation',
    title: '画面を名前付きで呼ぶメソッド',
    level: 2,
    type: 'fill_blank',
    statement:
      '名前付きルート "/detail" へ遷移したいです。\n空欄に入るメソッド名を答えてください。\n\nNavigator.__________(context, "/detail");',
    requirements: '空欄にはメソッド名だけを書いてください。',
    hint: 'push の名前付きルート版です。',
    answer: 'pushNamed',
    explanation:
      '名前付きルートへ遷移するときは Navigator.pushNamed を使います。',
    common_mistakes:
      'goNamed は標準の Navigator API ではありません。',
    display_order: 2404,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-031',
    theme_id: 'local-flutter-navigation',
    title: '前画面へ値を返すpop',
    level: 2,
    type: 'fill_blank',
    statement:
      '選択した文字列 "done" を前の画面へ返しながら戻りたいです。\n空欄に入るコード全体を答えてください。\n\n__________',
    requirements: 'Navigator を使った1行で答えてください。',
    hint: 'pop の第2引数に戻り値を渡せます。',
    answer: 'Navigator.pop(context, "done");',
    explanation:
      'Navigator.pop(context, 値) と書くと、戻ると同時に前画面へ値を返せます。',
    common_mistakes:
      'push に値を渡すのではなく、戻るときに pop で返すのがポイントです。',
    display_order: 2405,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-032',
    theme_id: 'local-flutter-navigation',
    title: 'push結果を待つ型',
    level: 3,
    type: 'fill_blank',
    statement:
      '画面遷移の戻り値を String 型で待ちたいです。\n空欄に入る await 式全体を答えてください。\n\nfinal result = __________;',
    requirements: 'Navigator.push と MaterialPageRoute を使ってください。',
    hint: 'push は Future を返すので await できます。',
    answer: 'await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => NextPage()))',
    explanation:
      'Navigator.push<T> の T に戻り値型を書いておくと、受け取る側の型が明確になります。',
    common_mistakes:
      'await を付けないと、結果ではなく Future 自体を受け取ることになります。',
    display_order: 2406,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-033',
    theme_id: 'local-flutter-api',
    title: 'HTTP GETでよく使うメソッド名',
    level: 1,
    type: 'fill_blank',
    statement:
      'APIから一覧取得するときによく使うHTTPメソッドを答えてください。\n\nHTTP __________',
    requirements: '空欄には大文字のメソッド名を書いてください。',
    hint: '取得系APIの代表です。',
    answer: 'GET',
    explanation:
      '一覧取得や詳細取得など、読む系のAPIでは GET を使うことが多いです。',
    common_mistakes:
      'POST は作成系で使うことが多く、取得系とは役割が違います。',
    display_order: 2501,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-034',
    theme_id: 'local-flutter-api',
    title: 'JSON文字列をMapへ変換する関数',
    level: 1,
    type: 'fill_blank',
    statement:
      'JSON文字列を Dart の Map へ変換したいです。\n空欄に入る関数名を答えてください。\n\nfinal data = __________(response.body);',
    requirements: '空欄には関数名だけを書いてください。',
    hint: 'dart:convert からよく使います。',
    answer: 'jsonDecode',
    explanation:
      'jsonDecode を使うと、JSON文字列を Dart のオブジェクトへ変換できます。',
    common_mistakes:
      'decodeJson という標準関数名ではありません。',
    display_order: 2502,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-035',
    theme_id: 'local-flutter-api',
    title: 'Futureを受け取って描画するWidget',
    level: 1,
    type: 'fill_blank',
    statement:
      '非同期取得したデータの状態に応じて画面を切り替えたいです。\n空欄に入るWidget名を答えてください。\n\n__________<Task>(',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'future と builder を取る代表Widgetです。',
    answer: 'FutureBuilder',
    explanation:
      'FutureBuilder を使うと、読み込み中・成功・失敗で表示を切り替えやすくなります。',
    common_mistakes:
      'StreamBuilder は継続的なデータ流れ向けで、1回取得のFutureとは少し用途が違います。',
    display_order: 2503,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-036',
    theme_id: 'local-flutter-api',
    title: '読み込み中に表示する基本Widget',
    level: 1,
    type: 'fill_blank',
    statement:
      '通信中であることを示すクルクルした表示の基本Widget名を答えてください。\n\n__________()',
    requirements: '空欄にはWidget名だけを書いてください。',
    hint: 'ローディング表示の定番です。',
    answer: 'CircularProgressIndicator',
    explanation:
      'CircularProgressIndicator は読み込み中を示す代表的なWidgetです。',
    common_mistakes:
      'LoadingWidget という標準Widget名ではありません。',
    display_order: 2504,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-037',
    theme_id: 'local-flutter-api',
    title: 'HTTPレスポンスの本文プロパティ',
    level: 2,
    type: 'fill_blank',
    statement:
      'http パッケージの response から本文文字列を取り出したいです。\n空欄に入るプロパティ名を答えてください。\n\nresponse.__________',
    requirements: '空欄にはプロパティ名だけを書いてください。',
    hint: 'JSONを decode するときによく使います。',
    answer: 'body',
    explanation:
      'response.body にレスポンス本文の文字列が入っています。',
    common_mistakes:
      'data ではなく body が http パッケージの代表的プロパティです。',
    display_order: 2505,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-038',
    theme_id: 'local-flutter-api',
    title: 'ステータスコード成功判定',
    level: 2,
    type: 'fill_blank',
    statement:
      'HTTP通信成功時だけ処理を進めたいです。\n空欄に入る条件式だけを答えてください。\n\nif (__________) {\n  return response.body;\n}',
    requirements: '200番の成功判定を書いてください。',
    hint: '代表的な成功コードです。',
    answer: 'response.statusCode == 200',
    explanation:
      'HTTP 200 は取得成功の代表的なステータスコードです。',
    common_mistakes:
      'response.code という標準プロパティ名ではありません。',
    display_order: 2506,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-039',
    theme_id: 'local-flutter-api',
    title: 'モデルへ変換するfactory宣言',
    level: 2,
    type: 'fill_blank',
    statement:
      'Map<String, dynamic> から Task モデルを作る factory を定義したいです。\n空欄に入る宣言だけを答えてください。\n\nclass Task {\n  final int id;\n  final String title;\n\n  __________ {\n    return Task(id: json["id"], title: json["title"]);\n  }\n}',
    requirements: 'factory コンストラクタの宣言を書いてください。',
    hint: 'fromJson という名前がよく使われます。',
    answer: 'factory Task.fromJson(Map<String, dynamic> json)',
    explanation:
      'fromJson という factory を作ると、APIレスポンスからモデル生成しやすくなります。',
    common_mistakes:
      '戻り値型を別で書く通常メソッドではなく、factory 構文を使うのがポイントです。',
    display_order: 2507,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-040',
    theme_id: 'local-flutter-api',
    title: '通信失敗時に投げる基本例外',
    level: 3,
    type: 'fill_blank',
    statement:
      'ステータスコードが 200 以外なら例外を投げたいです。\n空欄に入るコード全体を答えてください。\n\nif (response.statusCode != 200) {\n  __________\n}',
    requirements: '簡単な文字列メッセージ付きで例外を投げてください。',
    hint: 'throw と Exception を使います。',
    answer: 'throw Exception("Failed to load data");',
    explanation:
      '通信失敗時は throw Exception(...) のように例外化して、呼び出し側で扱えるようにします。',
    common_mistakes:
      'print だけでは失敗が上位へ伝わらず、UI側で適切にエラー表示しにくくなります。',
    display_order: 2508,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-041',
    theme_id: 'local-flutter-widget-basic',
    title: 'StatelessWidgetでHello画面を書く',
    level: 2,
    type: 'normal',
    statement:
      '`HelloPage` という `StatelessWidget` を作り、`Scaffold` の `body` に `Center(child: Text("Hello"))` を表示するコードを書いてください。',
    requirements:
      '`StatelessWidget` を継承すること\n`build` メソッドを書くこと\n`Scaffold` と `Center` と `Text("Hello")` を使うこと',
    hint: 'Flutter の最初の1画面を自分で書けるかを確かめる問題です。',
    answer:
      'class HelloPage extends StatelessWidget {\n  const HelloPage({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      body: Center(\n        child: Text("Hello"),\n      ),\n    );\n  }\n}',
    explanation:
      'Widget 基礎では、最小の画面を `StatelessWidget` で自力実装できることが大事です。',
    common_mistakes:
      '`return` せずに Widget を並べるだけだと `build` メソッドとして成立しません。',
    display_order: 2509,
    themes: createFlutterTheme('Flutter: Widget基礎'),
  },
  {
    id: 'local-flutter-042',
    theme_id: 'local-flutter-state',
    title: 'カウンターを増やすStatefulWidgetを書く',
    level: 2,
    type: 'normal',
    statement:
      'ボタンを押すたびに `counter` が 1 増える簡単な `StatefulWidget` の `build` 部分を書いてください。',
    requirements:
      '`Text("$counter")` を表示すること\n`ElevatedButton` を置くこと\n`onPressed` の中で `setState` を使って `counter++` すること',
    hint: '状態管理の最初の練習として、`setState` の位置を意識してください。',
    answer:
      'Column(\n  mainAxisAlignment: MainAxisAlignment.center,\n  children: [\n    Text("$counter"),\n    ElevatedButton(\n      onPressed: () {\n        setState(() {\n          counter++;\n        });\n      },\n      child: Text("増やす"),\n    ),\n  ],\n)',
    explanation:
      '`setState` の中で状態を変えるのが Flutter 基礎の重要ポイントです。',
    common_mistakes:
      '`counter++` だけ書いて `setState` を呼ばないと画面が更新されません。',
    display_order: 2510,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-043',
    theme_id: 'local-flutter-layout',
    title: '余白付きの縦並びレイアウトを書く',
    level: 2,
    type: 'normal',
    statement:
      '画面中央に `タイトル` と `説明` を縦並びで表示し、全体に 16 の余白を付けるコードを書いてください。',
    requirements:
      '`Padding` を使うこと\n`Column` を使うこと\n`Text("タイトル")` と `Text("説明")` を含めること',
    hint: '1つの Widget に全部詰め込まず、外側から順に組み立てると書きやすいです。',
    answer:
      'Padding(\n  padding: const EdgeInsets.all(16),\n  child: Column(\n    mainAxisSize: MainAxisSize.min,\n    children: const [\n      Text("タイトル"),\n      Text("説明"),\n    ],\n  ),\n)',
    explanation:
      'Flutter のレイアウトは、`Padding` と `Column` の組み合わせをまず自然に書けるようになると強いです。',
    common_mistakes:
      '`Container` だけで何でも済ませようとすると、役割が曖昧になって読みづらくなります。',
    display_order: 2511,
    themes: createFlutterTheme('Flutter: レイアウト'),
  },
  {
    id: 'local-flutter-044',
    theme_id: 'local-flutter-navigation',
    title: '詳細画面へ遷移するコードを書く',
    level: 2,
    type: 'normal',
    statement:
      'ボタン押下で `DetailPage()` へ遷移する `onPressed` のコードを書いてください。',
    requirements:
      '`Navigator.push` を使うこと\n`MaterialPageRoute` を使うこと\n`DetailPage()` を返すこと',
    hint: 'Flutter の画面遷移は `context` と `route` をセットで考えると整理しやすいです。',
    answer:
      'onPressed: () {\n  Navigator.push(\n    context,\n    MaterialPageRoute(\n      builder: (context) => DetailPage(),\n    ),\n  );\n}',
    explanation:
      '明示的な画面遷移は `Navigator.push` が基本です。',
    common_mistakes:
      '`Navigator.pop` は戻る処理なので、新しい画面へ進むときには使いません。',
    display_order: 2512,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-045',
    theme_id: 'local-flutter-navigation',
    title: '前の画面へ結果を返して戻るコードを書く',
    level: 3,
    type: 'normal',
    statement:
      '詳細画面から `"saved"` という文字列を前の画面へ返して閉じるコードを1行で書いてください。',
    requirements:
      '`Navigator.pop` を使うこと\n`context` を渡すこと\n戻り値として `"saved"` を渡すこと',
    hint: '画面を閉じるだけでなく、戻り値を付けられる形です。',
    answer: 'Navigator.pop(context, "saved");',
    explanation:
      'Flutter では `pop` に値を渡すことで、前画面へ結果を返せます。',
    common_mistakes:
      '`Navigator.push` に値を渡しても戻り値にはなりません。',
    display_order: 2513,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-046',
    theme_id: 'local-flutter-api',
    title: 'TaskモデルのfromJsonを書く',
    level: 2,
    type: 'normal',
    statement:
      '`id` と `title` を持つ `Task` モデルに、`Map<String, dynamic>` から変換する `fromJson` を書いてください。',
    requirements:
      '`factory Task.fromJson(...)` を書くこと\n`json["id"]` と `json["title"]` を使うこと\n`Task(...)` を返すこと',
    hint: 'API 連携では、JSON をそのまま UI へ渡さずモデルへ変換する流れが重要です。',
    answer:
      'class Task {\n  final int id;\n  final String title;\n\n  Task({required this.id, required this.title});\n\n  factory Task.fromJson(Map<String, dynamic> json) {\n    return Task(\n      id: json["id"],\n      title: json["title"],\n    );\n  }\n}',
    explanation:
      '`fromJson` を自分で書けると、API レスポンスを扱う土台がかなり安定します。',
    common_mistakes:
      '`json.id` のようにドット記法で読むと `Map` のアクセスとしては誤りです。',
    display_order: 2514,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-047',
    theme_id: 'local-flutter-api',
    title: 'APIから一覧を取得する関数を書く',
    level: 3,
    type: 'normal',
    statement:
      '`https://example.com/tasks` からデータを取得し、成功時は `response.body` を返し、失敗時は例外を投げる `fetchTasks` 関数を書いてください。',
    requirements:
      '`async` を使うこと\n`http.get(Uri.parse(...))` を使うこと\n`response.statusCode == 200` を判定すること',
    hint: 'まずは返り値を JSON 変換する前の文字列でも大丈夫です。',
    answer:
      'Future<String> fetchTasks() async {\n  final response = await http.get(Uri.parse("https://example.com/tasks"));\n\n  if (response.statusCode == 200) {\n    return response.body;\n  }\n\n  throw Exception("Failed to load tasks");\n}',
    explanation:
      'API 連携の基本は、通信・成功判定・失敗時の例外処理を一連で書けることです。',
    common_mistakes:
      '`await` を付け忘れると `response` が `Future` のままになり、後続処理でつまずきます。',
    display_order: 2515,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-048',
    theme_id: 'local-flutter-api',
    title: 'FutureBuilderで読み込み中と成功時を描き分ける',
    level: 3,
    type: 'normal',
    statement:
      '`future: fetchTasks()` を使う `FutureBuilder<String>` の `builder` を書いてください。読み込み中は `CircularProgressIndicator`、成功時は `Text(snapshot.data!)` を表示してください。',
    requirements:
      '`snapshot.connectionState == ConnectionState.waiting` を判定すること\n読み込み中表示を書くこと\n成功時の `Text(snapshot.data!)` を書くこと',
    hint: '最初はエラー分岐がなくても大丈夫ですが、待機中分岐は必須です。',
    answer:
      'FutureBuilder<String>(\n  future: fetchTasks(),\n  builder: (context, snapshot) {\n    if (snapshot.connectionState == ConnectionState.waiting) {\n      return const CircularProgressIndicator();\n    }\n\n    return Text(snapshot.data!);\n  },\n)',
    explanation:
      '`FutureBuilder` は非同期データを UI に反映する基本パターンです。',
    common_mistakes:
      '`snapshot.data` を待機中から直接使うと `null` で落ちやすくなります。',
    display_order: 2516,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-049',
    theme_id: 'local-flutter-state',
    title: 'TextFieldの入力値をボタン押下で使うコードを書く',
    level: 3,
    type: 'normal',
    statement:
      '`TextEditingController controller` を使って、ボタンを押したら `print(controller.text);` を実行するコードを書いてください。',
    requirements:
      '`TextField(controller: controller)` を含めること\n`ElevatedButton` を使うこと\n`onPressed` の中で `print(controller.text);` を呼ぶこと',
    hint: '入力イベントで毎回保存する形ではなく、コントローラから読む形です。',
    answer:
      'Column(\n  children: [\n    TextField(controller: controller),\n    ElevatedButton(\n      onPressed: () {\n        print(controller.text);\n      },\n      child: Text("送信"),\n    ),\n  ],\n)',
    explanation:
      'フォーム入力では `TextEditingController` を通して値を読むパターンをよく使います。',
    common_mistakes:
      '`controller.value` だけを書くと、文字列そのものではなく別の情報を扱うことになりやすいです。',
    display_order: 2517,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-050',
    theme_id: 'local-flutter-state',
    title: '画面表示時にAPI取得を始めるinitStateを書く',
    level: 3,
    type: 'normal',
    statement:
      '`Future<String> taskFuture` を画面表示時に `fetchTasks()` で初期化したいです。`State` クラス内の `initState` を書いてください。',
    requirements:
      '`@override` を書くこと\n`super.initState();` を呼ぶこと\n`taskFuture = fetchTasks();` を書くこと',
    hint: '最初の API 呼び出しは `build` の中より `initState` に置く方が安定します。',
    answer:
      '@override\nvoid initState() {\n  super.initState();\n  taskFuture = fetchTasks();\n}',
    explanation:
      '`initState` は画面初期化時に一度だけ走らせたい処理を書く場所です。',
    common_mistakes:
      '`build` の中で毎回 `fetchTasks()` を呼ぶと、再描画のたびに通信が走りやすくなります。',
    display_order: 2518,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-051',
    theme_id: 'local-flutter-api',
    title: '一覧取得して表示するTaskList画面を書く',
    level: 3,
    type: 'normal',
    statement:
      '`fetchTasks()` が `Future<List<Task>>` を返す前提で、読み込み中はローディング、成功時は `ListView.builder` でタイトル一覧を表示する `FutureBuilder` を書いてください。',
    requirements:
      '`FutureBuilder<List<Task>>` を使うこと\n待機中は `CircularProgressIndicator` を表示すること\n成功時は `ListView.builder` と `Text(tasks[index].title)` を使うこと',
    hint: '研修では API から一覧取得して画面に出す流れを 1 つ書けるとかなり強いです。',
    answer:
      'FutureBuilder<List<Task>>(\n  future: fetchTasks(),\n  builder: (context, snapshot) {\n    if (snapshot.connectionState == ConnectionState.waiting) {\n      return const Center(child: CircularProgressIndicator());\n    }\n\n    final tasks = snapshot.data!;\n\n    return ListView.builder(\n      itemCount: tasks.length,\n      itemBuilder: (context, index) {\n        return ListTile(\n          title: Text(tasks[index].title),\n        );\n      },\n    );\n  },\n)',
    explanation:
      '非同期取得と一覧表示をまとめて書けるようになると、Flutter 研修の課題にかなり対応しやすくなります。',
    common_mistakes:
      '待機中分岐なしで `snapshot.data!` を使うと、読み込み前に null 参照しやすくなります。',
    display_order: 2519,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-052',
    theme_id: 'local-flutter-navigation',
    title: '新規作成画面で入力して結果を返す処理を書く',
    level: 3,
    type: 'normal',
    statement:
      '`TextEditingController controller` を使ってタスク名を入力し、保存ボタンを押したら `Navigator.pop(context, controller.text)` で前画面へ返す `onPressed` のコードを書いてください。',
    requirements:
      '`controller.text` を使うこと\n`Navigator.pop(context, ...)` を使うこと\n戻り値として入力文字列を返すこと',
    hint: '一覧画面から作成画面へ遷移して、戻ってきた値を受け取る流れの一部です。',
    answer:
      'onPressed: () {\n  Navigator.pop(context, controller.text);\n}',
    explanation:
      '研修では「別画面で入力して戻り値を返す」程度の画面連携がよく出ます。',
    common_mistakes:
      '`Navigator.push` を使うと画面が増えるだけで、前画面へ結果を返す処理にはなりません。',
    display_order: 2520,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
  {
    id: 'local-flutter-053',
    theme_id: 'local-flutter-state',
    title: 'buildのたびにAPIが再実行される原因と修正方針を書く',
    level: 3,
    type: 'normal',
    statement:
      '`build` メソッドの中で `fetchTasks()` を毎回呼んでいるため、画面更新のたびに API 通信が走っています。原因と修正方針を1つずつ書いてください。',
    requirements:
      '原因として `build` が再実行されるたびに通信が走ることを書くこと\n修正方針として `initState` で `Future` を一度だけ作ることを書くこと',
    hint: 'Flutter では「どこで非同期処理を開始するか」がかなり重要です。',
    answer:
      '原因: `build` は再描画のたびに呼ばれるので、その中で `fetchTasks()` を呼ぶと毎回通信が走る\n修正方針: `initState` で `taskFuture = fetchTasks();` を一度だけ実行し、その `Future` を `FutureBuilder` に渡す',
    explanation:
      '実務や研修では、コードを書くだけでなく「なぜ重複通信が起きるのか」を説明できる力も大切です。',
    common_mistakes:
      '`setState` を減らすだけでは根本解決にならず、通信開始位置を直す必要があります。',
    display_order: 2521,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-054',
    theme_id: 'local-flutter-state',
    title: 'setState を呼ばずに画面が更新されないバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次のコードではボタンを押しても画面の数字が変わりません。正しく動くように修正した `onPressed` のコードを書いてください。\n\n```dart\nint count = 0;\n\nonPressed: () {\n  count++;\n}\n```',
    requirements:
      '`setState` を使うこと\n`count++` の更新を中に入れること',
    hint: 'StatefulWidget で画面を再描画させたいときに必要な関数を思い出してください。',
    answer:
      'onPressed: () {\n  setState(() {\n    count++;\n  });\n}',
    explanation:
      'StatefulWidget では値を変えるだけでは再描画されません。`setState` の中で更新して初めて画面に反映されます。',
    common_mistakes:
      '`count++` だけ書くと内部の値は変わっても UI は更新されません。画面更新の通知までセットで必要です。',
    display_order: 2522,
    themes: createFlutterTheme('Flutter: 状態管理'),
  },
  {
    id: 'local-flutter-055',
    theme_id: 'local-flutter-api',
    title: 'build のたびに API を呼ぶバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次のコードは画面更新のたびに `fetchTasks()` が走ってしまいます。1回だけ取得する形に直す方針を、原因と修正コードつきで書いてください。\n\n```dart\n@override\nWidget build(BuildContext context) {\n  return FutureBuilder(\n    future: fetchTasks(),\n    builder: (context, snapshot) {\n      return Container();\n    },\n  );\n}\n```',
    requirements:
      '原因を 1 つ書くこと\n`initState` で `Future` を保持する修正を書くこと\n`FutureBuilder` でその `Future` を使うこと',
    hint: '`build` は何度も呼ばれるので、重い処理や API 呼び出しを毎回その場で作らない構成にします。',
    answer:
      '原因: `build` が再実行されるたびに `fetchTasks()` を新しく呼んでいるため。\n\nlate Future<List<Task>> taskFuture;\n\n@override\nvoid initState() {\n  super.initState();\n  taskFuture = fetchTasks();\n}\n\n@override\nWidget build(BuildContext context) {\n  return FutureBuilder<List<Task>>(\n    future: taskFuture,\n    builder: (context, snapshot) {\n      return Container();\n    },\n  );\n}',
    explanation:
      '初回取得を `initState` に寄せて `Future` を保持しておくと、不要な再通信を防げます。',
    common_mistakes:
      '`setState` を足すだけでは原因は解消しません。問題は再描画時に API 呼び出し自体を作り直している点です。',
    display_order: 2523,
    themes: createFlutterTheme('Flutter: API連携'),
  },
  {
    id: 'local-flutter-056',
    theme_id: 'local-flutter-navigation',
    title: '戻るときに値を返せない Navigator のバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '入力画面でタスク名を入力して前の画面へ返したいのに、次のコードだと値が返りません。正しい `onPressed` を書いてください。\n\n```dart\nonPressed: () {\n  Navigator.push(context,\n    MaterialPageRoute(builder: (context) => const TaskListPage()),\n  );\n}\n```',
    requirements:
      '`Navigator.pop` を使うこと\n`controller.text` を返すこと',
    hint: 'すでに開いている入力画面から前の画面へ戻すときは、さらに push せず、現在の画面を閉じます。',
    answer:
      'onPressed: () {\n  Navigator.pop(context, controller.text);\n}',
    explanation:
      '値を返しながら前画面へ戻るときは `Navigator.pop(context, value)` を使います。`push` では新しい画面を開くだけです。',
    common_mistakes:
      '一覧画面へもう一度 `push` すると画面が増えるだけで、戻り値は受け取れません。',
    display_order: 2524,
    themes: createFlutterTheme('Flutter: 画面遷移'),
  },
]

export const LOCAL_PHP_PROBLEMS: ProblemRecord[] = [
  {
    id: 'local-php-001',
    theme_id: 'local-php-basic',
    title: 'PHPの変数で先頭に付ける記号',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP で変数を宣言するとき、変数名の先頭に付ける記号を書いてください。\n\n__________name = "Taro";',
    requirements: '記号だけを書くこと',
    hint: 'Java の変数宣言とは書き方が違います。',
    answer: '$',
    explanation:
      'PHP の変数は `$name` のように、必ず `$` を付けて表現します。',
    common_mistakes:
      '`var` や `String` は型や宣言方法の話で、変数名の先頭に付ける記号ではありません。',
    display_order: 3101,
    themes: createPhpTheme('PHP: 基本文法'),
  },
  {
    id: 'local-php-002',
    theme_id: 'local-php-basic',
    title: '文字を画面に出力する命令',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP で文字列を画面に表示するときによく使う命令を書いてください。\n\n<?php __________ "Hello"; ?>',
    requirements: '命令名だけを書くこと',
    hint: '最初の PHP 学習でよく出てくる出力命令です。',
    answer: 'echo',
    explanation:
      '`echo` は PHP で文字列や値をそのまま出力するときの基本です。',
    common_mistakes:
      '`println` は Java で使う書き方で、PHP の基本出力ではありません。',
    display_order: 3102,
    themes: createPhpTheme('PHP: 基本文法'),
  },
  {
    id: 'local-php-003',
    theme_id: 'local-php-basic',
    title: '文字列を結合する演算子',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP で `"Hello"` と `"World"` を結合するときに使う演算子を書いてください。\n\n"Hello" __________ "World"',
    requirements: '演算子だけを書くこと',
    hint: 'Java の `+` とは違います。',
    answer: '.',
    explanation:
      'PHP の文字列結合はドット `.` を使います。',
    common_mistakes:
      '`+` は PHP では文字列結合の基本演算子ではありません。',
    display_order: 3103,
    themes: createPhpTheme('PHP: 基本文法'),
  },
  {
    id: 'local-php-004',
    theme_id: 'local-php-basic',
    title: '関数を定義するときのキーワード',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP で関数を定義するときに使うキーワードを書いてください。\n\n__________ greet() {\n  echo "Hi";\n}',
    requirements: 'キーワードだけを書くこと',
    hint: 'Java のメソッド定義に似ていますが、書き出しは別です。',
    answer: 'function',
    explanation:
      'PHP で関数を作るときは `function` を使います。',
    common_mistakes:
      '`def` は Python の書き方で、PHP では使いません。',
    display_order: 3104,
    themes: createPhpTheme('PHP: 基本文法'),
  },
  {
    id: 'local-php-005',
    theme_id: 'local-php-basic',
    title: '配列の短縮構文',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP で配列を短く書くときに使う記号を書いてください。\n\n$items = __________;',
    requirements: '記号だけを書くこと',
    hint: '空配列を作るときの書き方です。',
    answer: '[]',
    explanation:
      'PHP では `[]` で空配列を作れます。',
    common_mistakes:
      '`{}` は配列ではなく、別の意味で使われることがあります。',
    display_order: 3105,
    themes: createPhpTheme('PHP: 基本文法'),
  },
  {
    id: 'local-php-006',
    theme_id: 'local-php-request',
    title: 'GETパラメータを受け取る変数',
    level: 1,
    type: 'fill_blank',
    statement:
      'URL のクエリパラメータを PHP で受け取るスーパーグローバル変数を書いてください。\n\n__________["id"]',
    requirements: '変数名だけを書くこと',
    hint: '`?id=1` のような値を受け取るときに使います。',
    answer: '$_GET',
    explanation:
      'GET パラメータは `$_GET` から取得します。',
    common_mistakes:
      '`$_POST` はフォームの POST 送信時に使うもので、GET 専用ではありません。',
    display_order: 3201,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-007',
    theme_id: 'local-php-request',
    title: 'POSTデータを受け取る変数',
    level: 1,
    type: 'fill_blank',
    statement:
      'フォームから POST 送信された値を PHP で受け取るスーパーグローバル変数を書いてください。\n\n__________["title"]',
    requirements: '変数名だけを書くこと',
    hint: '登録フォームでよく使います。',
    answer: '$_POST',
    explanation:
      'POST データは `$_POST` から取り出します。',
    common_mistakes:
      '`$_GET` を使うと送信方式が合わず、値が取れないことがあります。',
    display_order: 3202,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-008',
    theme_id: 'local-php-request',
    title: 'フォームをPOST送信にする属性値',
    level: 1,
    type: 'fill_blank',
    statement:
      'HTML フォームを POST 送信にするとき、`method` 属性に入れる値を書いてください。\n\n<form method="__________">',
    requirements: '値だけを書くこと',
    hint: '大文字小文字は一般的な小文字で答えてください。',
    answer: 'post',
    explanation:
      '`<form method="post">` と書くことで POST 送信になります。',
    common_mistakes:
      '`POST` でも意味は通じますが、HTML では通常小文字で統一されます。',
    display_order: 3203,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-009',
    theme_id: 'local-php-request',
    title: '入力欄の値を送るための属性',
    level: 1,
    type: 'fill_blank',
    statement:
      'フォーム送信時に PHP 側で値を受け取れるように、`input` タグに必ず付けたい属性を書いてください。\n\n<input type="text" __________="title">',
    requirements: '属性名だけを書くこと',
    hint: '`$_POST["title"]` の `"title"` に対応します。',
    answer: 'name',
    explanation:
      '`name` 属性がないと、フォーム送信しても PHP から値を取り出せません。',
    common_mistakes:
      '`id` は見た目や JavaScript 用で、送信名そのものではありません。',
    display_order: 3204,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-010',
    theme_id: 'local-php-request',
    title: '空入力を確認する関数',
    level: 1,
    type: 'fill_blank',
    statement:
      '入力値が空かどうかを確かめる PHP の基本関数を書いてください。\n\nif (__________($title)) {\n  echo "必須です";\n}',
    requirements: '関数名だけを書くこと',
    hint: '必須チェックでよく使います。',
    answer: 'empty',
    explanation:
      '`empty()` は値が空かどうかを簡単に判定できます。',
    common_mistakes:
      '`isEmpty` は Java 風の名前で、PHP の標準関数ではありません。',
    display_order: 3205,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-011',
    theme_id: 'local-php-request',
    title: 'HTTPメソッドを確認する変数',
    level: 2,
    type: 'fill_blank',
    statement:
      '現在のリクエストが GET か POST かを確認するときによく使う変数名を書いてください。\n\n$_SERVER["__________"]',
    requirements: 'キー名だけを書くこと',
    hint: '`REQUEST_` から始まる名前です。',
    answer: 'REQUEST_METHOD',
    explanation:
      '`$_SERVER["REQUEST_METHOD"]` で GET / POST などを確認できます。',
    common_mistakes:
      '`METHOD` だけではキー名として足りません。',
    display_order: 3206,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-012',
    theme_id: 'local-php-crud',
    title: '一覧表示で配列を回す構文',
    level: 1,
    type: 'fill_blank',
    statement:
      'タスク一覧配列 `$tasks` を1件ずつ取り出して表示するときに使う構文を書いてください。\n\n__________ ($tasks as $task) {\n  echo $task["title"];\n}',
    requirements: '構文キーワードだけを書くこと',
    hint: '配列の繰り返し処理です。',
    answer: 'foreach',
    explanation:
      '`foreach` は配列の各要素を順番に処理するときに使います。',
    common_mistakes:
      '`for` でも書けますが、この形の穴埋めでは `foreach` が正解です。',
    display_order: 3301,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-013',
    theme_id: 'local-php-crud',
    title: '連想配列からtitleを取り出す書き方',
    level: 1,
    type: 'fill_blank',
    statement:
      '連想配列 `$task` から title を取り出すコードを書いてください。\n\n$task[__________]',
    requirements: 'キーだけを書くこと',
    hint: '文字列キーです。',
    answer: '"title"',
    explanation:
      '連想配列の値は `$task["title"]` のようにキーで取得します。',
    common_mistakes:
      '`title` だけだと文字列として扱われず、意図しない動きになります。',
    display_order: 3302,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-014',
    theme_id: 'local-php-crud',
    title: '配列の件数を数える関数',
    level: 1,
    type: 'fill_blank',
    statement:
      '配列 `$tasks` の件数を調べる PHP の関数を書いてください。\n\n__________($tasks)',
    requirements: '関数名だけを書くこと',
    hint: '一覧件数表示などでよく使います。',
    answer: 'count',
    explanation:
      '`count()` で配列の要素数を取得できます。',
    common_mistakes:
      '`size` は Java のコレクションでよく出ますが、PHP の標準関数ではありません。',
    display_order: 3303,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-015',
    theme_id: 'local-php-crud',
    title: '配列の末尾に要素を追加する関数',
    level: 2,
    type: 'fill_blank',
    statement:
      '配列 `$tasks` の末尾に新しいタスクを追加する関数を書いてください。\n\n__________($tasks, $newTask);',
    requirements: '関数名だけを書くこと',
    hint: '新規追加処理で使えます。',
    answer: 'array_push',
    explanation:
      '`array_push()` で配列の末尾へ要素を追加できます。',
    common_mistakes:
      '`push` 単体は PHP の基本関数名ではありません。',
    display_order: 3304,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-016',
    theme_id: 'local-php-crud',
    title: '削除対象のidをGETで受け取る',
    level: 1,
    type: 'fill_blank',
    statement:
      'URL から削除対象の id を受け取るコードの空欄を埋めてください。\n\n$id = $_GET[__________];',
    requirements: 'キーだけを書くこと',
    hint: '`?id=3` のように受け取る想定です。',
    answer: '"id"',
    explanation:
      '`$_GET["id"]` とすることで、クエリパラメータの id を取得できます。',
    common_mistakes:
      '`id` を引用符なしで書くと、意図した文字列キーになりません。',
    display_order: 3305,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-017',
    theme_id: 'local-php-crud',
    title: '更新対象のidをhiddenで送るinput type',
    level: 2,
    type: 'fill_blank',
    statement:
      '編集フォームで id を見えないまま送信したいです。`input` タグの `type` 属性に入れる値を書いてください。\n\n<input type="__________" name="id" value="1">',
    requirements: '値だけを書くこと',
    hint: 'ユーザーには見せない入力欄です。',
    answer: 'hidden',
    explanation:
      '`type="hidden"` で画面に表示せず値を送れます。',
    common_mistakes:
      '`text` にすると普通の入力欄として表示されてしまいます。',
    display_order: 3306,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-018',
    theme_id: 'local-php-crud',
    title: 'リダイレクトに使う関数',
    level: 2,
    type: 'fill_blank',
    statement:
      '保存後に一覧画面へリダイレクトするときに使う PHP の関数を書いてください。\n\n__________("Location: list.php");',
    requirements: '関数名だけを書くこと',
    hint: 'HTTP ヘッダーを送る関数です。',
    answer: 'header',
    explanation:
      '`header("Location: ...")` でリダイレクトできます。',
    common_mistakes:
      '`redirect` という標準関数は PHP にはありません。',
    display_order: 3307,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-019',
    theme_id: 'local-php-crud',
    title: '条件に合う要素を見つけたら抜ける命令',
    level: 2,
    type: 'fill_blank',
    statement:
      'ループ中に目的の id を見つけたら処理を抜けたいです。使う命令を書いてください。\n\nif ($task["id"] == $id) {\n  __________;\n}',
    requirements: '命令だけを書くこと',
    hint: '繰り返しを途中で止めます。',
    answer: 'break',
    explanation:
      '`break` を使うと、その場でループ処理を終了できます。',
    common_mistakes:
      '`return` でも抜けられますが、この問題はループ制御命令を問っています。',
    display_order: 3308,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-020',
    theme_id: 'local-php-crud',
    title: '削除用リンクでidを付けるクエリ名',
    level: 1,
    type: 'fill_blank',
    statement:
      '削除リンク `delete.php?id=3` の `=` の左側にあるクエリ名を書いてください。\n\ndelete.php?__________=3',
    requirements: 'クエリ名だけを書くこと',
    hint: '対象の識別子です。',
    answer: 'id',
    explanation:
      '`id` をクエリ名にしておくと、削除対象を取り出しやすくなります。',
    common_mistakes:
      '`title` だと一意に対象を識別しにくいことがあります。',
    display_order: 3309,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-021',
    theme_id: 'local-php-crud',
    title: '新規登録後によく使うHTTP処理',
    level: 2,
    type: 'fill_blank',
    statement:
      'フォーム再送信を避けるため、登録後は一覧へ移動させることが多いです。この流れを一言で表すと何ですか。\n\n登録後に __________ する',
    requirements: 'カタカナ1語で答えること',
    hint: '`header("Location: ...")` で行う処理です。',
    answer: 'リダイレクト',
    explanation:
      '登録後にリダイレクトすると、再読み込み時の二重送信を避けやすくなります。',
    common_mistakes:
      '`更新` だと画面側の動作を正確に表しきれません。',
    display_order: 3310,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-022',
    theme_id: 'local-php-crud',
    title: '配列に保存した全件を表示する繰り返し構文',
    level: 1,
    type: 'fill_blank',
    statement:
      'タスク配列 `$tasks` の全件を順番に表示したいです。使う繰り返し構文を書いてください。\n\n__________ ($tasks as $task)',
    requirements: '構文キーワードだけを書くこと',
    hint: 'PHP の配列表示で最もよく使います。',
    answer: 'foreach',
    explanation:
      'PHP の配列を全件処理するときは `foreach` が基本です。',
    common_mistakes:
      '`while` だと条件や添字管理が必要になり、この形とは合いません。',
    display_order: 3311,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-023',
    theme_id: 'local-php-crud',
    title: '配列から1件を作る関数名',
    level: 1,
    type: 'fill_blank',
    statement:
      '連想配列を作るときによく使う PHP の関数名を書いてください。\n\n$task = __________("id" => 1, "title" => "買い物");',
    requirements: '関数名だけを書くこと',
    hint: '配列作成の古い書き方です。',
    answer: 'array',
    explanation:
      '`array(...)` は PHP の配列作成で昔から使われる書き方です。',
    common_mistakes:
      '`list` は展開用の構文で、配列作成関数ではありません。',
    display_order: 3312,
    themes: createPhpTheme('PHP: CRUD'),
  },
  {
    id: 'local-php-024',
    theme_id: 'local-php-db',
    title: 'PHPでDB接続に使う基本クラス',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP でデータベース接続を行うときに学習でよく使うクラス名を書いてください。\n\nnew __________($dsn, $user, $password)',
    requirements: 'クラス名だけを書くこと',
    hint: 'MySQL や PostgreSQL 接続で広く使われます。',
    answer: 'PDO',
    explanation:
      '`PDO` は PHP の代表的な DB 接続手段です。',
    common_mistakes:
      '`JDBC` は Java の API 名なので、PHP では使いません。',
    display_order: 3401,
    themes: createPhpTheme('PHP: DB連携'),
  },
  {
    id: 'local-php-025',
    theme_id: 'local-php-db',
    title: 'MySQL接続用DSNの先頭',
    level: 1,
    type: 'fill_blank',
    statement:
      'PDO で MySQL に接続するとき、DSN の先頭に付ける文字列を書いてください。\n\n__________:host=localhost;dbname=task_app;charset=utf8mb4',
    requirements: '先頭部分だけを書くこと',
    hint: '接続先の種類を表します。',
    answer: 'mysql',
    explanation:
      'MySQL の PDO 接続では DSN を `mysql:...` から始めます。',
    common_mistakes:
      '`jdbc:mysql` は Java 側の書式で、PDO DSN とは異なります。',
    display_order: 3402,
    themes: createPhpTheme('PHP: DB連携'),
  },
  {
    id: 'local-php-026',
    theme_id: 'local-php-db',
    title: 'SQL文を安全に準備するメソッド',
    level: 2,
    type: 'fill_blank',
    statement:
      'PDO で SQL を実行する前に安全な形で準備するときのメソッド名を書いてください。\n\n$stmt = $pdo->__________("SELECT * FROM tasks WHERE id = ?");',
    requirements: 'メソッド名だけを書くこと',
    hint: 'SQL インジェクション対策でも重要です。',
    answer: 'prepare',
    explanation:
      '`prepare()` で SQL を準備し、あとから値を渡す形にできます。',
    common_mistakes:
      '`query` は簡単に実行できますが、値埋め込みでは安全性が下がりやすいです。',
    display_order: 3403,
    themes: createPhpTheme('PHP: DB連携'),
  },
  {
    id: 'local-php-027',
    theme_id: 'local-php-db',
    title: '準備したSQLを実行するメソッド',
    level: 2,
    type: 'fill_blank',
    statement:
      'prepare した SQL を実際に動かすメソッド名を書いてください。\n\n$stmt->__________([$id]);',
    requirements: 'メソッド名だけを書くこと',
    hint: 'prepare の次に使います。',
    answer: 'execute',
    explanation:
      '`execute()` で準備済み SQL を実行します。',
    common_mistakes:
      '`run` は PDOStatement の標準メソッドではありません。',
    display_order: 3404,
    themes: createPhpTheme('PHP: DB連携'),
  },
  {
    id: 'local-php-028',
    theme_id: 'local-php-db',
    title: '検索結果を全件取得するメソッド',
    level: 2,
    type: 'fill_blank',
    statement:
      'SELECT の結果を全件まとめて取得するメソッド名を書いてください。\n\n$tasks = $stmt->__________();',
    requirements: 'メソッド名だけを書くこと',
    hint: '一覧表示でよく使います。',
    answer: 'fetchAll',
    explanation:
      '`fetchAll()` で結果セットをまとめて受け取れます。',
    common_mistakes:
      '`fetch` は1件ずつ取得する形で、全件まとめてではありません。',
    display_order: 3405,
    themes: createPhpTheme('PHP: DB連携'),
  },
  {
    id: 'local-php-029',
    theme_id: 'local-php-db',
    title: '名前付きプレースホルダへ値を入れるメソッド',
    level: 3,
    type: 'fill_blank',
    statement:
      'PDO の名前付きプレースホルダ `:title` に値をセットするメソッド名を書いてください。\n\n$stmt->__________(":title", $title);',
    requirements: 'メソッド名だけを書くこと',
    hint: 'execute に直接配列を渡さない形です。',
    answer: 'bindValue',
    explanation:
      '`bindValue()` でプレースホルダへ値を関連付けられます。',
    common_mistakes:
      '`setValue` は PDOStatement の標準メソッドではありません。',
    display_order: 3406,
    themes: createPhpTheme('PHP: DB連携'),
  },
  {
    id: 'local-php-030',
    theme_id: 'local-php-security',
    title: 'XSS対策で出力前に使う関数',
    level: 1,
    type: 'fill_blank',
    statement:
      'ユーザー入力を画面へそのまま出さず、安全に表示するためによく使う関数を書いてください。\n\necho __________($title, ENT_QUOTES, "UTF-8");',
    requirements: '関数名だけを書くこと',
    hint: '`<script>` などをそのまま表示させないための対策です。',
    answer: 'htmlspecialchars',
    explanation:
      '`htmlspecialchars()` は XSS 対策の基本で、出力時に特殊文字をエスケープします。',
    common_mistakes:
      '`strip_tags` だけでは出力時エスケープの代わりになりません。',
    display_order: 3501,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-031',
    theme_id: 'local-php-security',
    title: 'SQLインジェクション対策の基本手法',
    level: 2,
    type: 'fill_blank',
    statement:
      'SQL インジェクション対策として、値を直接文字列連結せずに使う基本手法を書いてください。\n\n__________ statement',
    requirements: '英単語2語で答えること',
    hint: 'PDO の prepare と一緒に覚える重要語です。',
    answer: 'prepared',
    explanation:
      'prepared statement を使うと、値と SQL 構造を分けて扱えます。',
    common_mistakes:
      '`escape statement` という一般的な用語は使いません。',
    display_order: 3502,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-032',
    theme_id: 'local-php-security',
    title: 'CSRF対策でサーバ側に保存しやすい領域',
    level: 2,
    type: 'fill_blank',
    statement:
      'CSRF トークンをサーバ側に保存して比較するときに、PHP でよく使う仕組みを書いてください。\n\n__________',
    requirements: '英単語で答えること',
    hint: '`$_SESSION` と関係があります。',
    answer: 'session',
    explanation:
      'CSRF トークンは session に保存してフォーム送信値と比較する構成が基本です。',
    common_mistakes:
      '`cookie` だけに置くと比較元として扱いにくく、基本形としては session が先です。',
    display_order: 3503,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-033',
    theme_id: 'local-php-security',
    title: 'パスワードを安全にハッシュ化する関数',
    level: 2,
    type: 'fill_blank',
    statement:
      'パスワードを安全に保存するために、PHP でハッシュ化するときの基本関数を書いてください。\n\n$hash = __________($password, PASSWORD_DEFAULT);',
    requirements: '関数名だけを書くこと',
    hint: '平文保存は避けます。',
    answer: 'password_hash',
    explanation:
      '`password_hash()` はパスワード保存時の基本関数です。',
    common_mistakes:
      '`md5` は学習初期でも推奨されない古い方法です。',
    display_order: 3504,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-034',
    theme_id: 'local-php-security',
    title: 'ログイン時にハッシュ照合する関数',
    level: 2,
    type: 'fill_blank',
    statement:
      '入力パスワードと保存済みハッシュを照合するときの関数名を書いてください。\n\nif (__________($password, $hash)) {\n  echo "OK";\n}',
    requirements: '関数名だけを書くこと',
    hint: '`password_hash` と対になる関数です。',
    answer: 'password_verify',
    explanation:
      '`password_verify()` で平文入力と保存済みハッシュを比較できます。',
    common_mistakes:
      '`password_check` は標準関数ではありません。',
    display_order: 3505,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-035',
    theme_id: 'local-php-security',
    title: 'CSRFトークンをフォームで送るinput type',
    level: 2,
    type: 'fill_blank',
    statement:
      'CSRF トークンをフォームに含めるとき、`input` タグの `type` 属性に入れる値を書いてください。\n\n<input type="__________" name="token" value="<?= $token ?>">',
    requirements: '値だけを書くこと',
    hint: '画面には見せない値です。',
    answer: 'hidden',
    explanation:
      'CSRF トークンは hidden input で送るのが基本形です。',
    common_mistakes:
      '`text` にすると画面に出てしまい、フォームとして不自然です。',
    display_order: 3506,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-036',
    theme_id: 'local-php-java-common',
    title: '条件分岐の基本キーワード',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP でも Java でも条件分岐で使う基本キーワードを書いてください。\n\n__________ ($score >= 80) {\n  echo "合格";\n}',
    requirements: 'キーワードだけを書くこと',
    hint: '両言語で共通です。',
    answer: 'if',
    explanation:
      '`if` は PHP と Java のどちらでも基本的な条件分岐で使います。',
    common_mistakes:
      '`when` はこの2言語の基本構文ではありません。',
    display_order: 3601,
    themes: createPhpTheme('PHP: Javaとの共通理解'),
  },
  {
    id: 'local-php-037',
    theme_id: 'local-php-java-common',
    title: '繰り返し処理の基本キーワード',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP と Java の両方で使う、基本的な繰り返し処理のキーワードを書いてください。\n\n__________ ($i = 0; $i < 3; $i++) {\n  echo $i;\n}',
    requirements: 'キーワードだけを書くこと',
    hint: '添字つきの繰り返しです。',
    answer: 'for',
    explanation:
      '`for` は両言語で共通して使う繰り返し構文です。',
    common_mistakes:
      '`repeat` はどちらの基本構文でもありません。',
    display_order: 3602,
    themes: createPhpTheme('PHP: Javaとの共通理解'),
  },
  {
    id: 'local-php-038',
    theme_id: 'local-php-java-common',
    title: '値を返すキーワード',
    level: 1,
    type: 'fill_blank',
    statement:
      '関数やメソッドから値を返すときに使うキーワードを書いてください。\n\n__________ $result;',
    requirements: 'キーワードだけを書くこと',
    hint: 'PHP でも Java でも共通です。',
    answer: 'return',
    explanation:
      '`return` は処理結果を呼び出し元へ返すときの基本キーワードです。',
    common_mistakes:
      '`yield` は別用途で、基本の返却とは違います。',
    display_order: 3603,
    themes: createPhpTheme('PHP: Javaとの共通理解'),
  },
  {
    id: 'local-php-039',
    theme_id: 'local-php-java-common',
    title: 'クラス定義のキーワード',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP でも Java でもクラス定義で使うキーワードを書いてください。\n\n__________ Task {',
    requirements: 'キーワードだけを書くこと',
    hint: 'オブジェクト指向の基本です。',
    answer: 'class',
    explanation:
      '`class` は両言語でクラスを定義するときの共通キーワードです。',
    common_mistakes:
      '`object` は型の概念としては近くても、定義キーワードではありません。',
    display_order: 3604,
    themes: createPhpTheme('PHP: Javaとの共通理解'),
  },
  {
    id: 'local-php-040',
    theme_id: 'local-php-java-common',
    title: '公開メンバを表すアクセス修飾子',
    level: 1,
    type: 'fill_blank',
    statement:
      'PHP と Java のどちらでも、公開されたメソッドやプロパティによく使うアクセス修飾子を書いてください。\n\n__________ function save() {',
    requirements: '修飾子だけを書くこと',
    hint: '`private` の反対側で考えると出やすいです。',
    answer: 'public',
    explanation:
      '`public` は外部からアクセス可能にするときの基本修飾子です。',
    common_mistakes:
      '`open` はこの2言語のアクセス修飾子ではありません。',
    display_order: 3605,
    themes: createPhpTheme('PHP: Javaとの共通理解'),
  },
  {
    id: 'local-php-041',
    theme_id: 'local-php-request',
    title: 'POST受け取りと必須チェックを行う保存処理を書く',
    level: 3,
    type: 'normal',
    statement:
      'フォームから送られた `title` を `$_POST` で受け取り、空ならエラー表示、空でなければ `list.php` へリダイレクトする PHP コードを書いてください。',
    requirements:
      '`$_POST["title"]` を使うこと\n`empty($title)` で必須チェックすること\n正常時は `header("Location: list.php");` を使うこと',
    hint: '研修では、フォーム受け取りから簡単な分岐までを 1 つの流れで書く問題がよく出ます。',
    answer:
      '$title = $_POST["title"];\n\nif (empty($title)) {\n  echo "タイトルは必須です";\n} else {\n  header("Location: list.php");\n}',
    explanation:
      'PHP の基本力として、受け取り・バリデーション・分岐・リダイレクトを一連で書けることは重要です。',
    common_mistakes:
      '`name` 属性と `$_POST` のキー名がずれると、受け取り自体ができなくなります。',
    display_order: 3606,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-042',
    theme_id: 'local-php-db',
    title: 'PDOで更新処理を書く',
    level: 3,
    type: 'normal',
    statement:
      '`id` と `title` を受け取り、`tasks` テーブルのタイトルを更新する PDO のコードを書いてください。',
    requirements:
      '`prepare` を使うこと\n`UPDATE tasks SET title = ? WHERE id = ?` を書くこと\n`execute([$title, $id])` を使うこと',
    hint: '研修では SELECT だけでなく UPDATE を安全に書けるかもよく見られます。',
    answer:
      '$stmt = $pdo->prepare("UPDATE tasks SET title = ? WHERE id = ?");\n$stmt->execute([$title, $id]);',
    explanation:
      '更新処理でも prepared statement を使うことで、安全で読みやすいコードになります。',
    common_mistakes:
      'SQL を文字列連結で組み立てると、ミスや SQL インジェクションの温床になりやすいです。',
    display_order: 3607,
    themes: createPhpTheme('PHP: DB連携'),
  },
  {
    id: 'local-php-043',
    theme_id: 'local-php-security',
    title: '一覧画面でXSS対策しながらタイトル表示を書く',
    level: 3,
    type: 'normal',
    statement:
      '`$tasks` の各要素にある `title` を一覧表示したいです。XSS 対策をしながら表示する `foreach` のコードを書いてください。',
    requirements:
      '`foreach ($tasks as $task)` を使うこと\n`htmlspecialchars($task["title"], ENT_QUOTES, "UTF-8")` を使うこと\n`echo` で出力すること',
    hint: 'PHP では保存時よりも「出力時エスケープ」を確実にするのが基本です。',
    answer:
      'foreach ($tasks as $task) {\n  echo htmlspecialchars($task["title"], ENT_QUOTES, "UTF-8");\n}',
    explanation:
      '一覧表示は単純に見えて、XSS 対策を含めて書けるかが実践力の差になりやすいです。',
    common_mistakes:
      '`echo $task["title"];` のままだと、悪意ある文字列をそのまま表示してしまう可能性があります。',
    display_order: 3608,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-044',
    theme_id: 'local-php-request',
    title: 'フォームの name 不一致で値が取れないバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次のフォーム送信後、`$_POST["title"]` が取れません。原因を直した HTML を書いてください。\n\n```php\n<form method="post" action="save.php">\n  <input type="text" name="task_title">\n  <button type="submit">保存</button>\n</form>\n```\n\n```php\n$title = $_POST["title"];\n```',
    requirements:
      '原因が `name` の不一致であることを反映すること\n修正後のフォーム HTML を書くこと',
    hint: '`$_POST["title"]` で受けるなら、フォーム側の `name` も同じキーで送る必要があります。',
    answer:
      '<form method="post" action="save.php">\n  <input type="text" name="title">\n  <button type="submit">保存</button>\n</form>',
    explanation:
      'PHP は `name` 属性をキーとして送信値を受け取ります。キー名がずれると `$_POST["title"]` には入りません。',
    common_mistakes:
      '`id` を変えても `$_POST` のキーは直りません。送信値に影響するのは `name` 属性です。',
    display_order: 3609,
    themes: createPhpTheme('PHP: リクエスト処理'),
  },
  {
    id: 'local-php-045',
    theme_id: 'local-php-security',
    title: 'XSS 対策なしで表示しているバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次の一覧表示は XSS の危険があります。安全に表示するコードへ修正してください。\n\n```php\nforeach ($tasks as $task) {\n  echo $task["title"];\n}\n```',
    requirements:
      '`htmlspecialchars` を使うこと\n`ENT_QUOTES` と `UTF-8` を指定すること',
    hint: 'ユーザー入力をそのまま HTML に出すと危険です。表示前にエスケープします。',
    answer:
      'foreach ($tasks as $task) {\n  echo htmlspecialchars($task["title"], ENT_QUOTES, "UTF-8");\n}',
    explanation:
      'HTML に埋め込む前にエスケープすることで、悪意あるタグやスクリプトがそのまま実行されるのを防げます。',
    common_mistakes:
      '`strip_tags` だけでは不十分なケースがあります。表示時の基本は `htmlspecialchars` です。',
    display_order: 3610,
    themes: createPhpTheme('PHP: セキュリティ'),
  },
  {
    id: 'local-php-046',
    theme_id: 'local-php-db',
    title: 'PDO で execute し忘れて更新されないバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次のコードは SQL を準備していますが、実行されないためデータが更新されません。正しく動くコードを書いてください。\n\n```php\n$stmt = $pdo->prepare("UPDATE tasks SET title = ? WHERE id = ?");\n```',
    requirements:
      '`execute([$title, $id])` を使うこと\n2 つの値を正しい順で渡すこと',
    hint: 'PDO は `prepare` だけでは実行されません。プレースホルダに値を渡して実行する処理が必要です。',
    answer:
      '$stmt = $pdo->prepare("UPDATE tasks SET title = ? WHERE id = ?");\n$stmt->execute([$title, $id]);',
    explanation:
      '`prepare` は実行準備までです。実際に DB を更新するには `execute` が必要です。',
    common_mistakes:
      '`execute([$id, $title])` のように順番を逆にすると、意図しない値で更新されます。',
    display_order: 3611,
    themes: createPhpTheme('PHP: DB連携'),
  },
]

export const LOCAL_HTML_CSS_PROBLEMS: ProblemRecord[] = [
  {
    id: 'local-html-css-001',
    theme_id: 'local-html-css-html-basic',
    title: 'HTML文書の開始タグ',
    level: 1,
    type: 'fill_blank',
    statement:
      'HTML 文書の最上位で使う開始タグを書いてください。\n\n<__________>',
    requirements: 'タグ名だけを書くこと',
    hint: 'ページ全体を囲むタグです。',
    answer: 'html',
    explanation:
      '`<html>` は HTML 文書全体を表す基本タグです。',
    common_mistakes:
      '`body` は本文用で、文書全体を囲む最上位タグではありません。',
    display_order: 4101,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-002',
    theme_id: 'local-html-css-html-basic',
    title: 'ページタイトルを入れるタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      'ブラウザのタブに表示されるタイトルを入れるタグを書いてください。\n\n<__________>My Page</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: '`head` の中に書くことが多いです。',
    answer: 'title',
    explanation:
      '`<title>` はブラウザタブや検索結果のタイトルとして使われます。',
    common_mistakes:
      '`h1` はページ本文の見出しで、タブタイトルではありません。',
    display_order: 4102,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-003',
    theme_id: 'local-html-css-html-basic',
    title: '本文を囲むタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      '画面に表示される本文を囲むタグを書いてください。\n\n<__________>\n  <h1>Hello</h1>\n</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: '見出しや文章などを入れる領域です。',
    answer: 'body',
    explanation:
      '`<body>` の中に、画面へ表示したい HTML を書きます。',
    common_mistakes:
      '`head` は設定やメタ情報用で、本文表示用ではありません。',
    display_order: 4103,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-004',
    theme_id: 'local-html-css-html-basic',
    title: '最も大きい見出しタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      'HTML で最も大きい見出しに使うタグを書いてください。\n\n<__________>見出し</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: '`h` から始まる見出しタグの最初です。',
    answer: 'h1',
    explanation:
      '`<h1>` はページ内で最上位の見出しとして使います。',
    common_mistakes:
      '`title` はブラウザタブ用で、本文の見出しではありません。',
    display_order: 4104,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-005',
    theme_id: 'local-html-css-html-basic',
    title: '段落を表すタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      '文章の段落を表すタグを書いてください。\n\n<__________>これは説明文です。</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: '`paragraph` の頭文字です。',
    answer: 'p',
    explanation:
      '`<p>` は文章の段落を表す基本タグです。',
    common_mistakes:
      '`span` はインライン要素で、段落全体の意味づけとは異なります。',
    display_order: 4105,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-006',
    theme_id: 'local-html-css-html-basic',
    title: '画像を表示するタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      '画像を表示するタグを書いてください。\n\n<__________ src="cat.png" alt="猫">',
    requirements: 'タグ名だけを書くこと',
    hint: '`image` ではなく短い形です。',
    answer: 'img',
    explanation:
      '`<img>` は画像を表示するためのタグです。',
    common_mistakes:
      '`image` は HTML の標準タグ名ではありません。',
    display_order: 4106,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-007',
    theme_id: 'local-html-css-html-basic',
    title: 'リンク先URLを入れる属性',
    level: 1,
    type: 'fill_blank',
    statement:
      'リンクタグで遷移先 URL を指定する属性を書いてください。\n\n<a __________="https://example.com">サイトへ</a>',
    requirements: '属性名だけを書くこと',
    hint: '`https://...` を入れる場所です。',
    answer: 'href',
    explanation:
      '`href` はリンク先 URL を表す属性です。',
    common_mistakes:
      '`src` は画像やスクリプトでよく使いますが、リンク先指定ではありません。',
    display_order: 4107,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-008',
    theme_id: 'local-html-css-html-basic',
    title: '横並びで意味を持たない汎用タグ',
    level: 2,
    type: 'fill_blank',
    statement:
      '主にインライン要素として使う、意味を持たない汎用タグを書いてください。\n\n<__________ class="highlight">重要</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: '`div` のインライン版です。',
    answer: 'span',
    explanation:
      '`<span>` は文字の一部など、インライン範囲へスタイルを当てたいときに使います。',
    common_mistakes:
      '`div` はブロック要素なので、同じ役割ではありません。',
    display_order: 4108,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-009',
    theme_id: 'local-html-css-form',
    title: 'フォーム全体を囲むタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      '入力欄や送信ボタンをまとめるタグを書いてください。\n\n<__________ action=\"save.php\" method=\"post\">',
    requirements: 'タグ名だけを書くこと',
    hint: '送信先や送信方式を指定します。',
    answer: 'form',
    explanation:
      '`<form>` で入力要素をまとめて送信できます。',
    common_mistakes:
      '`input` は入力欄1つを表すタグで、フォーム全体ではありません。',
    display_order: 4201,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-010',
    theme_id: 'local-html-css-form',
    title: '1行入力欄を作るタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      '1 行のテキスト入力欄を作るタグを書いてください。\n\n<__________ type=\"text\" name=\"title\">',
    requirements: 'タグ名だけを書くこと',
    hint: 'フォームで最もよく使う入力タグです。',
    answer: 'input',
    explanation:
      '`<input>` はテキストやチェックボックスなど多くの入力に使えます。',
    common_mistakes:
      '`textarea` は複数行入力用です。',
    display_order: 4202,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-011',
    theme_id: 'local-html-css-form',
    title: '複数行入力欄のタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      '複数行の文章を入力できるタグを書いてください。\n\n<__________ name=\"message\"></__________>',
    requirements: 'タグ名だけを書くこと',
    hint: '問い合わせフォームの本文などで使います。',
    answer: 'textarea',
    explanation:
      '`<textarea>` は複数行テキスト入力用のタグです。',
    common_mistakes:
      '`input` は基本的に1行入力です。',
    display_order: 4203,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-012',
    theme_id: 'local-html-css-form',
    title: 'ラベルと入力欄を関連付けるタグ',
    level: 1,
    type: 'fill_blank',
    statement:
      '入力欄の説明文として使い、クリックで入力欄にフォーカスしやすくなるタグを書いてください。\n\n<__________ for=\"email\">メールアドレス</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: 'アクセシビリティでも重要です。',
    answer: 'label',
    explanation:
      '`<label>` を使うと、入力欄の意味がわかりやすくなります。',
    common_mistakes:
      '`span` では説明文として見えても、関連付けの意味は持てません。',
    display_order: 4204,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-013',
    theme_id: 'local-html-css-form',
    title: '送信ボタンに使うtype属性',
    level: 1,
    type: 'fill_blank',
    statement:
      'フォーム送信ボタンにしたいとき、`button` タグの `type` に入れる値を書いてください。\n\n<button type=\"__________\">送信</button>',
    requirements: '値だけを書くこと',
    hint: 'フォームを送信する役割です。',
    answer: 'submit',
    explanation:
      '`type="submit"` にするとフォーム送信ボタンになります。',
    common_mistakes:
      '`button` はタグ名で、type 属性の値ではありません。',
    display_order: 4205,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-014',
    theme_id: 'local-html-css-form',
    title: '選択肢をプルダウン表示するタグ',
    level: 2,
    type: 'fill_blank',
    statement:
      '都道府県などをプルダウンで選ばせるときに使うタグを書いてください。\n\n<__________ name=\"prefecture\">',
    requirements: 'タグ名だけを書くこと',
    hint: '中に `option` を入れます。',
    answer: 'select',
    explanation:
      '`<select>` は複数候補から1つ以上選ぶ UI に使います。',
    common_mistakes:
      '`option` は中の選択肢で、外側のタグではありません。',
    display_order: 4206,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-015',
    theme_id: 'local-html-css-css-basic',
    title: 'CSSで文字色を変えるプロパティ',
    level: 1,
    type: 'fill_blank',
    statement:
      '文字色を赤にしたいときに使う CSS プロパティを書いてください。\n\n__________: red;',
    requirements: 'プロパティ名だけを書くこと',
    hint: '背景色ではありません。',
    answer: 'color',
    explanation:
      '`color` は文字の色を変える基本プロパティです。',
    common_mistakes:
      '`background-color` は背景色を変えるものです。',
    display_order: 4301,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-016',
    theme_id: 'local-html-css-css-basic',
    title: '背景色を変えるプロパティ',
    level: 1,
    type: 'fill_blank',
    statement:
      '要素の背景色を青にしたいときに使う CSS プロパティを書いてください。\n\n__________: blue;',
    requirements: 'プロパティ名だけを書くこと',
    hint: '文字色ではなく背景です。',
    answer: 'background-color',
    explanation:
      '`background-color` で背景色を指定できます。',
    common_mistakes:
      '`color` は文字色なので用途が違います。',
    display_order: 4302,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-017',
    theme_id: 'local-html-css-css-basic',
    title: '文字サイズを変えるプロパティ',
    level: 1,
    type: 'fill_blank',
    statement:
      '文字サイズを 24px にしたいときの CSS プロパティを書いてください。\n\n__________: 24px;',
    requirements: 'プロパティ名だけを書くこと',
    hint: '`font` から始まる基本プロパティです。',
    answer: 'font-size',
    explanation:
      '`font-size` で文字の大きさを調整できます。',
    common_mistakes:
      '`text-size` は CSS の基本プロパティではありません。',
    display_order: 4303,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-018',
    theme_id: 'local-html-css-css-basic',
    title: '外側の余白を表すプロパティ',
    level: 1,
    type: 'fill_blank',
    statement:
      '要素の外側に余白を付ける CSS プロパティを書いてください。\n\n__________: 16px;',
    requirements: 'プロパティ名だけを書くこと',
    hint: '内側の余白ではありません。',
    answer: 'margin',
    explanation:
      '`margin` は要素の外側の余白です。',
    common_mistakes:
      '`padding` は内側の余白です。',
    display_order: 4304,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-019',
    theme_id: 'local-html-css-css-basic',
    title: '内側の余白を表すプロパティ',
    level: 1,
    type: 'fill_blank',
    statement:
      '要素の内側に余白を付ける CSS プロパティを書いてください。\n\n__________: 12px;',
    requirements: 'プロパティ名だけを書くこと',
    hint: 'border の内側の余白です。',
    answer: 'padding',
    explanation:
      '`padding` は要素の内側の余白です。',
    common_mistakes:
      '`margin` は外側の余白なので意味が違います。',
    display_order: 4305,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-020',
    theme_id: 'local-html-css-css-basic',
    title: '枠線を付けるプロパティ',
    level: 1,
    type: 'fill_blank',
    statement:
      '要素に `1px solid #ccc` の枠線を付ける CSS プロパティを書いてください。\n\n__________: 1px solid #ccc;',
    requirements: 'プロパティ名だけを書くこと',
    hint: 'ボックスの縁を表します。',
    answer: 'border',
    explanation:
      '`border` で太さ・線種・色をまとめて指定できます。',
    common_mistakes:
      '`outline` とは別の基本プロパティです。',
    display_order: 4306,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-021',
    theme_id: 'local-html-css-css-basic',
    title: 'classセレクタの記号',
    level: 1,
    type: 'fill_blank',
    statement:
      'CSS で class セレクタを書くとき、クラス名の前に付ける記号を書いてください。\n\n__________card {',
    requirements: '記号だけを書くこと',
    hint: 'id セレクタとは違う記号です。',
    answer: '.',
    explanation:
      'class セレクタは `.card` のようにドットで書きます。',
    common_mistakes:
      '`#` は id セレクタで使う記号です。',
    display_order: 4307,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-022',
    theme_id: 'local-html-css-css-basic',
    title: 'idセレクタの記号',
    level: 1,
    type: 'fill_blank',
    statement:
      'CSS で id セレクタを書くとき、id 名の前に付ける記号を書いてください。\n\n__________header {',
    requirements: '記号だけを書くこと',
    hint: 'class セレクタの `.` とは別です。',
    answer: '#',
    explanation:
      'id セレクタは `#header` のようにシャープで書きます。',
    common_mistakes:
      '`.` は class セレクタなので用途が異なります。',
    display_order: 4308,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-023',
    theme_id: 'local-html-css-layout',
    title: 'Flexboxを有効にするdisplayの値',
    level: 2,
    type: 'fill_blank',
    statement:
      '親要素で Flexbox を使いたいとき、`display` に入れる値を書いてください。\n\ndisplay: __________;',
    requirements: '値だけを書くこと',
    hint: '横並びレイアウトでよく使います。',
    answer: 'flex',
    explanation:
      '`display: flex;` で Flexbox レイアウトが有効になります。',
    common_mistakes:
      '`block` では Flexbox は有効になりません。',
    display_order: 4401,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-024',
    theme_id: 'local-html-css-layout',
    title: 'Flexboxで横方向に中央揃えするプロパティ',
    level: 2,
    type: 'fill_blank',
    statement:
      'Flexbox で主軸方向に中央揃えしたいです。使う CSS プロパティを書いてください。\n\n__________: center;',
    requirements: 'プロパティ名だけを書くこと',
    hint: '横並びなら左右中央揃えに関係します。',
    answer: 'justify-content',
    explanation:
      '`justify-content` は主軸方向の並び方を制御します。',
    common_mistakes:
      '`align-items` は交差軸方向なので、意味が違います。',
    display_order: 4402,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-025',
    theme_id: 'local-html-css-layout',
    title: 'Flexboxで縦方向に中央揃えするプロパティ',
    level: 2,
    type: 'fill_blank',
    statement:
      'Flexbox で交差軸方向に中央揃えしたいです。使う CSS プロパティを書いてください。\n\n__________: center;',
    requirements: 'プロパティ名だけを書くこと',
    hint: '横並びなら上下中央揃えに関係します。',
    answer: 'align-items',
    explanation:
      '`align-items` は交差軸方向の配置を制御します。',
    common_mistakes:
      '`justify-content` は主軸方向です。',
    display_order: 4403,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-026',
    theme_id: 'local-html-css-layout',
    title: '要素を縦並びにするflex-directionの値',
    level: 2,
    type: 'fill_blank',
    statement:
      'Flexbox で要素を縦並びにしたいです。`flex-direction` に入れる値を書いてください。\n\nflex-direction: __________;',
    requirements: '値だけを書くこと',
    hint: '列方向を表します。',
    answer: 'column',
    explanation:
      '`flex-direction: column;` で要素を縦方向へ並べられます。',
    common_mistakes:
      '`row` は横並びです。',
    display_order: 4404,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-027',
    theme_id: 'local-html-css-layout',
    title: '中央寄せレイアウトで横幅指定によく使う単位',
    level: 2,
    type: 'fill_blank',
    statement:
      'コンテンツ幅を `960` の画面幅基準で指定したいとき、`width: 960__________;` に入れる単位を書いてください。',
    requirements: '単位だけを書くこと',
    hint: '固定幅の基本単位です。',
    answer: 'px',
    explanation:
      '`px` は固定サイズ指定で最も基本的な単位です。',
    common_mistakes:
      '`%` は親要素基準なので、固定幅指定とは意味が異なります。',
    display_order: 4405,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-028',
    theme_id: 'local-html-css-layout',
    title: '要素を非表示にするdisplayの値',
    level: 1,
    type: 'fill_blank',
    statement:
      '要素を表示しないようにしたいとき、`display` に入れる値を書いてください。\n\ndisplay: __________;',
    requirements: '値だけを書くこと',
    hint: '完全に表示されなくなります。',
    answer: 'none',
    explanation:
      '`display: none;` で要素を画面上から非表示にできます。',
    common_mistakes:
      '`hidden` は `visibility` の値として使うことがありますが、ここでは `display` の値を問っています。',
    display_order: 4406,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-029',
    theme_id: 'local-html-css-layout',
    title: '角を丸くするプロパティ',
    level: 1,
    type: 'fill_blank',
    statement:
      'ボタンの角を丸くするときに使う CSS プロパティを書いてください。\n\n__________: 8px;',
    requirements: 'プロパティ名だけを書くこと',
    hint: 'border と一緒によく使います。',
    answer: 'border-radius',
    explanation:
      '`border-radius` で角丸を指定できます。',
    common_mistakes:
      '`radius` だけでは CSS の基本プロパティとして成立しません。',
    display_order: 4407,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-030',
    theme_id: 'local-html-css-layout',
    title: '影を付けるプロパティ',
    level: 2,
    type: 'fill_blank',
    statement:
      'カードに影を付けるときによく使う CSS プロパティを書いてください。\n\n__________: 0 4px 12px rgba(0, 0, 0, 0.1);',
    requirements: 'プロパティ名だけを書くこと',
    hint: 'ボックス全体の影です。',
    answer: 'box-shadow',
    explanation:
      '`box-shadow` で要素に影を付けられます。',
    common_mistakes:
      '`text-shadow` は文字の影なので用途が違います。',
    display_order: 4408,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-031',
    theme_id: 'local-html-css-responsive',
    title: 'メディアクエリの開始キーワード',
    level: 2,
    type: 'fill_blank',
    statement:
      'レスポンシブ対応で画面幅ごとに CSS を切り替えるとき、書き始めに使うキーワードを書いてください。\n\n__________ (max-width: 768px) {',
    requirements: 'キーワードだけを書くこと',
    hint: '`@` から始まります。',
    answer: '@media',
    explanation:
      '`@media` を使うと、条件付きで CSS を適用できます。',
    common_mistakes:
      '`media` だけでは CSS の構文として不完全です。',
    display_order: 4501,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
  {
    id: 'local-html-css-032',
    theme_id: 'local-html-css-responsive',
    title: 'スマホ幅以下を表す比較条件',
    level: 2,
    type: 'fill_blank',
    statement:
      '画面幅が 768px 以下のときにスタイルを切り替えたいです。メディアクエリで使う条件名を書いてください。\n\n@media (__________: 768px) {',
    requirements: '条件名だけを書くこと',
    hint: '`min-width` の反対側です。',
    answer: 'max-width',
    explanation:
      '`max-width` を使うと、指定値以下の画面幅にスタイルを適用できます。',
    common_mistakes:
      '`min-width` だと指定値以上に適用されてしまいます。',
    display_order: 4502,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
  {
    id: 'local-html-css-033',
    theme_id: 'local-html-css-responsive',
    title: '画像を親幅に合わせる幅指定',
    level: 2,
    type: 'fill_blank',
    statement:
      '画像が親要素からはみ出ないように、幅を親に合わせて縮めたいです。`width` に入れる値を書いてください。\n\nimg {\n  width: __________;\n}',
    requirements: '値だけを書くこと',
    hint: '親の幅いっぱいを表します。',
    answer: '100%',
    explanation:
      '`width: 100%;` で親要素の幅に合わせやすくなります。',
    common_mistakes:
      '`100px` だと固定サイズになり、レスポンシブではありません。',
    display_order: 4503,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
  {
    id: 'local-html-css-034',
    theme_id: 'local-html-css-responsive',
    title: 'ビューポート設定で使うmetaタグ名',
    level: 2,
    type: 'fill_blank',
    statement:
      'スマホで適切に表示するために使う meta タグの `name` 属性値を書いてください。\n\n<meta name=\"__________\" content=\"width=device-width, initial-scale=1.0\">',
    requirements: '属性値だけを書くこと',
    hint: '画面幅に関係する英単語です。',
    answer: 'viewport',
    explanation:
      '`viewport` 設定はスマホ表示の基本です。',
    common_mistakes:
      '`screen` はこの meta 設定の名前ではありません。',
    display_order: 4504,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
  {
    id: 'local-html-css-035',
    theme_id: 'local-html-css-responsive',
    title: '横並びを折り返すflex-wrapの値',
    level: 3,
    type: 'fill_blank',
    statement:
      'カードが画面幅に応じて次の行へ折り返すようにしたいです。`flex-wrap` に入れる値を書いてください。\n\nflex-wrap: __________;',
    requirements: '値だけを書くこと',
    hint: '`nowrap` の反対です。',
    answer: 'wrap',
    explanation:
      '`flex-wrap: wrap;` で要素を折り返せます。',
    common_mistakes:
      '`break` は CSS の値ではありません。',
    display_order: 4505,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
  {
    id: 'local-html-css-036',
    theme_id: 'local-html-css-semantic',
    title: 'ページ上部の意味を持つタグ',
    level: 2,
    type: 'fill_blank',
    statement:
      'ページ上部やサイトのヘッダー領域に使うセマンティックタグを書いてください。\n\n<__________>\n  <h1>Site</h1>\n</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: 'HTML5 でよく使う意味付きタグです。',
    answer: 'header',
    explanation:
      '`<header>` はページやセクションの先頭部分を表す意味付きタグです。',
    common_mistakes:
      '`div` でも見た目は作れますが、意味づけとしては弱くなります。',
    display_order: 4601,
    themes: createHtmlCssTheme('HTML/CSS: セマンティック / アクセシビリティ'),
  },
  {
    id: 'local-html-css-037',
    theme_id: 'local-html-css-semantic',
    title: '主要なナビゲーションを表すタグ',
    level: 2,
    type: 'fill_blank',
    statement:
      'サイト内の主要リンク群を表すセマンティックタグを書いてください。\n\n<__________>\n  <a href=\"/\">Home</a>\n</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: 'メニューやグローバルナビで使います。',
    answer: 'nav',
    explanation:
      '`<nav>` は主要なナビゲーション領域を表します。',
    common_mistakes:
      '`menu` は一般的な主要ナビの基本タグとしてはまず `nav` を覚える方が自然です。',
    display_order: 4602,
    themes: createHtmlCssTheme('HTML/CSS: セマンティック / アクセシビリティ'),
  },
  {
    id: 'local-html-css-038',
    theme_id: 'local-html-css-semantic',
    title: 'ページの主要コンテンツを表すタグ',
    level: 2,
    type: 'fill_blank',
    statement:
      'そのページの中心となる主要コンテンツを表すタグを書いてください。\n\n<__________>\n  <article>...</article>\n</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: 'ページの主役となる内容です。',
    answer: 'main',
    explanation:
      '`<main>` はページの主要内容を表す意味付きタグです。',
    common_mistakes:
      '`body` はページ全体で、主要部分だけを表すタグではありません。',
    display_order: 4603,
    themes: createHtmlCssTheme('HTML/CSS: セマンティック / アクセシビリティ'),
  },
  {
    id: 'local-html-css-039',
    theme_id: 'local-html-css-semantic',
    title: '画像の代替説明に使う属性',
    level: 1,
    type: 'fill_blank',
    statement:
      '画像が読めないときの代替説明や読み上げのために使う属性を書いてください。\n\n<img src=\"logo.png\" __________=\"会社ロゴ\">',
    requirements: '属性名だけを書くこと',
    hint: 'アクセシビリティでも重要です。',
    answer: 'alt',
    explanation:
      '`alt` 属性は画像の意味を文字で伝えるために重要です。',
    common_mistakes:
      '`title` は補足表示であり、代替テキストの基本ではありません。',
    display_order: 4604,
    themes: createHtmlCssTheme('HTML/CSS: セマンティック / アクセシビリティ'),
  },
  {
    id: 'local-html-css-040',
    theme_id: 'local-html-css-semantic',
    title: 'ページ下部を表すセマンティックタグ',
    level: 2,
    type: 'fill_blank',
    statement:
      '著作権表示や補助リンクなど、ページ下部の領域を表すタグを書いてください。\n\n<__________>\n  <small>Copyright</small>\n</__________>',
    requirements: 'タグ名だけを書くこと',
    hint: 'header の反対側で覚えると出やすいです。',
    answer: 'footer',
    explanation:
      '`<footer>` はページやセクションの末尾情報を表します。',
    common_mistakes:
      '`bottom` は HTML の標準タグではありません。',
    display_order: 4605,
    themes: createHtmlCssTheme('HTML/CSS: セマンティック / アクセシビリティ'),
  },
  {
    id: 'local-html-css-041',
    theme_id: 'local-html-css-html-basic',
    title: '見出しと説明文の基本HTMLを書く',
    level: 2,
    type: 'normal',
    statement:
      'ページの先頭に「学習ダッシュボード」という見出しと、「今日の進捗を確認します。」という説明文を表示する HTML を書いてください。',
    requirements:
      '`h1` を使うこと\n説明文は `p` タグで書くこと\n2行の HTML にすること',
    hint: '最初の画面でよくある、見出し + 説明文の基本形です。',
    answer:
      '<h1>学習ダッシュボード</h1>\n<p>今日の進捗を確認します。</p>',
    explanation:
      'HTML の基本は、見出しと文章を適切な意味のタグで分けて書くことです。',
    common_mistakes:
      '`div` だけで全部書くと見た目は作れても、意味づけの練習として弱くなります。',
    display_order: 4606,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-042',
    theme_id: 'local-html-css-html-basic',
    title: '画像付きリンクのHTMLを書く',
    level: 2,
    type: 'normal',
    statement:
      '`logo.png` を表示し、その画像をクリックすると `/` へ移動する HTML を書いてください。代替テキストは「トップへ戻る」です。',
    requirements:
      '`a` タグを使うこと\n`img` タグを使うこと\n`href` と `alt` を正しく書くこと',
    hint: '画像をリンクで包む形です。',
    answer:
      '<a href="/">\n  <img src="logo.png" alt="トップへ戻る">\n</a>',
    explanation:
      'リンクと画像を組み合わせるときも、`href` と `alt` を忘れないのが基本です。',
    common_mistakes:
      '`img` に `href` を直接書いてもリンクにはなりません。',
    display_order: 4607,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-043',
    theme_id: 'local-html-css-form',
    title: 'お問い合わせフォームの最小HTMLを書く',
    level: 2,
    type: 'normal',
    statement:
      'POST で送信するお問い合わせフォームを書いてください。項目は「名前」の1つだけで、送信ボタンの文字は「送信」です。',
    requirements:
      '`form` タグに `method="post"` を書くこと\n`input` に `name="name"` を書くこと\n送信ボタンを付けること',
    hint: '最小構成なので、入力欄は1つで大丈夫です。',
    answer:
      '<form method="post">\n  <input type="text" name="name">\n  <button type="submit">送信</button>\n</form>',
    explanation:
      'フォームの基本は、送信方式・入力欄の name・送信ボタンの3点です。',
    common_mistakes:
      '`name` 属性がないと、サーバ側で値を受け取りにくくなります。',
    display_order: 4608,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-044',
    theme_id: 'local-html-css-form',
    title: 'ラベル付きメール入力欄のHTMLを書く',
    level: 2,
    type: 'normal',
    statement:
      '「メールアドレス」というラベルと、`email` 型の入力欄を関連付けた HTML を書いてください。id と name はどちらも `email` にします。',
    requirements:
      '`label` の `for` を使うこと\n`input type="email"` を使うこと\n`id="email"` と `name="email"` を書くこと',
    hint: 'ラベルと入力欄が対応する形にします。',
    answer:
      '<label for="email">メールアドレス</label>\n<input type="email" id="email" name="email">',
    explanation:
      'ラベルと入力欄を関連付けると、使いやすさとアクセシビリティが上がります。',
    common_mistakes:
      '`label` の `for` と `input` の `id` が一致しないと関連付けできません。',
    display_order: 4609,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-045',
    theme_id: 'local-html-css-css-basic',
    title: '見出しの色と大きさを変えるCSSを書く',
    level: 2,
    type: 'normal',
    statement:
      '`h1` の文字色を `#2563eb`、文字サイズを `32px` にする CSS を書いてください。',
    requirements:
      '`h1` セレクタを書くこと\n`color` を使うこと\n`font-size` を使うこと',
    hint: 'プロパティは2つだけです。',
    answer:
      'h1 {\n  color: #2563eb;\n  font-size: 32px;\n}',
    explanation:
      'CSS の基本は、セレクタを決めて必要なプロパティを素直に書くことです。',
    common_mistakes:
      '`text-color` のような名前は CSS の基本プロパティではありません。',
    display_order: 4610,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-046',
    theme_id: 'local-html-css-css-basic',
    title: 'カードに余白と枠線を付けるCSSを書く',
    level: 2,
    type: 'normal',
    statement:
      '`.card` クラスに、内側の余白 `16px`、外側の余白 `24px`、薄いグレーの枠線 `1px solid #ddd` を付ける CSS を書いてください。',
    requirements:
      '`.card` セレクタを書くこと\n`padding` と `margin` を使うこと\n`border` を書くこと',
    hint: '内側と外側の余白を混同しないのがポイントです。',
    answer:
      '.card {\n  padding: 16px;\n  margin: 24px;\n  border: 1px solid #ddd;\n}',
    explanation:
      'カード UI の基本は、padding・margin・border の役割を分けて書けることです。',
    common_mistakes:
      '`padding` と `margin` を逆にすると、見た目の意図がずれやすくなります。',
    display_order: 4611,
    themes: createHtmlCssTheme('HTML/CSS: CSS基礎'),
  },
  {
    id: 'local-html-css-047',
    theme_id: 'local-html-css-layout',
    title: 'Flexboxで横並び中央寄せのCSSを書く',
    level: 3,
    type: 'normal',
    statement:
      '`.menu` の子要素を横並びにし、左右中央寄せにする CSS を書いてください。',
    requirements:
      '`display: flex` を使うこと\n`justify-content: center` を書くこと',
    hint: '主軸方向の中央寄せです。',
    answer:
      '.menu {\n  display: flex;\n  justify-content: center;\n}',
    explanation:
      'Flexbox では、横並びの開始と主軸方向の配置をまずセットで覚えると使いやすいです。',
    common_mistakes:
      '`align-items: center` だけでは左右中央寄せにはなりません。',
    display_order: 4612,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-048',
    theme_id: 'local-html-css-layout',
    title: '縦並びレイアウトのCSSを書く',
    level: 3,
    type: 'normal',
    statement:
      '`.sidebar` の中身を縦方向に並べる Flexbox の CSS を書いてください。',
    requirements:
      '`display: flex` を使うこと\n`flex-direction: column` を書くこと',
    hint: '横並びから縦並びへ切り替える問題です。',
    answer:
      '.sidebar {\n  display: flex;\n  flex-direction: column;\n}',
    explanation:
      '`flex-direction: column` を書けると、UI の組み立ての幅がかなり広がります。',
    common_mistakes:
      '`column` だけ単独で書いても CSS として成立しません。',
    display_order: 4613,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-049',
    theme_id: 'local-html-css-responsive',
    title: 'スマホ幅で縦並びに切り替えるmedia queryを書く',
    level: 3,
    type: 'normal',
    statement:
      '通常は横並びの `.cards` を、画面幅 `768px` 以下では縦並びに切り替える CSS を書いてください。',
    requirements:
      '`@media (max-width: 768px)` を使うこと\n`.cards` に `flex-direction: column` を書くこと',
    hint: '親要素がすでに Flexbox になっている前提です。',
    answer:
      '@media (max-width: 768px) {\n  .cards {\n    flex-direction: column;\n  }\n}',
    explanation:
      'レスポンシブ対応では、どの幅で何を変えるかをはっきり書けることが大切です。',
    common_mistakes:
      '`min-width` を使うと、適用される画面幅の条件が逆になります。',
    display_order: 4614,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
  {
    id: 'local-html-css-050',
    theme_id: 'local-html-css-semantic',
    title: '意味付きレイアウトのHTMLを書く',
    level: 3,
    type: 'normal',
    statement:
      'ページ上部にサイト名、中央に主要コンテンツ、下部に著作権表示を持つ HTML を、意味付きタグで3行で書いてください。',
    requirements:
      '`header` を使うこと\n`main` を使うこと\n`footer` を使うこと',
    hint: '`div` ではなく、意味のあるタグを使う問題です。',
    answer:
      '<header>My Site</header>\n<main>主要コンテンツ</main>\n<footer>Copyright</footer>',
    explanation:
      'セマンティックタグを使うと、構造が読みやすくなり、意図も伝わりやすくなります。',
    common_mistakes:
      '`div` だけで構造を作ると、見た目は作れても意味の練習として弱くなります。',
    display_order: 4615,
    themes: createHtmlCssTheme('HTML/CSS: セマンティック / アクセシビリティ'),
  },
  {
    id: 'local-html-css-051',
    theme_id: 'local-html-css-html-basic',
    title: '学習アプリの基本レイアウトHTMLを書く',
    level: 3,
    type: 'normal',
    statement:
      'ページ上部にタイトル、中央に学習カード一覧、下部にフッターを持つ HTML を、意味付きタグで書いてください。',
    requirements:
      '`header` を使うこと\n中央は `main` を使うこと\nカード一覧は `section` を使ってよい\n下部は `footer` を使うこと',
    hint: '研修では見た目だけでなく、HTML 構造の意味づけも見られやすいです。',
    answer:
      '<header><h1>学習アプリ</h1></header>\n<main><section>カード一覧</section></main>\n<footer>Copyright</footer>',
    explanation:
      '意味付きタグを使ったレイアウトを書けると、構造理解と保守性の両方が上がります。',
    common_mistakes:
      '`div` だけで全部作ると見た目は成立しても、意味を持った構造の練習として弱くなります。',
    display_order: 4616,
    themes: createHtmlCssTheme('HTML/CSS: HTML基礎'),
  },
  {
    id: 'local-html-css-052',
    theme_id: 'local-html-css-layout',
    title: 'カード一覧を2列で並べるCSSを書く',
    level: 3,
    type: 'normal',
    statement:
      '`.cards` の中にあるカードを横並びで折り返し可能にし、カード同士の間隔を `16px` にする CSS を書いてください。',
    requirements:
      '`display: flex` を使うこと\n`flex-wrap: wrap` を使うこと\n`gap: 16px` を使うこと',
    hint: '今どきのカード一覧でよくある最小構成です。',
    answer:
      '.cards {\n  display: flex;\n  flex-wrap: wrap;\n  gap: 16px;\n}',
    explanation:
      'カード一覧では、Flexbox の開始・折り返し・間隔をセットで書けるとかなり実践的です。',
    common_mistakes:
      '`margin` だけで間隔を調整しようとすると、親子関係によってズレやすくなります。',
    display_order: 4617,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-053',
    theme_id: 'local-html-css-responsive',
    title: 'スマホ幅でカード一覧を1列にするCSSを書く',
    level: 3,
    type: 'normal',
    statement:
      '通常は複数列の `.cards` を、画面幅 `768px` 以下では 1 列表示にしたいです。メディアクエリ込みで CSS を書いてください。',
    requirements:
      '`@media (max-width: 768px)` を使うこと\n`.cards` に `flex-direction: column` を書くこと',
    hint: '既に `.cards` が Flexbox になっている前提で考えて大丈夫です。',
    answer:
      '@media (max-width: 768px) {\n  .cards {\n    flex-direction: column;\n  }\n}',
    explanation:
      '研修では、レイアウトを作るだけでなく、スマホ幅で崩れないように切り替える力もよく見られます。',
    common_mistakes:
      '`min-width` を使うと PC 側へ適用されやすくなり、意図と逆になることがあります。',
    display_order: 4618,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
  {
    id: 'local-html-css-054',
    theme_id: 'local-html-css-layout',
    title: 'HTML と CSS の class 名不一致バグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次の HTML と CSS ではスタイルが当たりません。原因を直した HTML を書いてください。\n\n```html\n<div class="card-list">\n  <div class="card">Task</div>\n</div>\n```\n\n```css\n.cards {\n  display: flex;\n  gap: 16px;\n}\n```',
    requirements:
      '原因が class 名の不一致であることを反映すること\n修正後の HTML を書くこと',
    hint: 'CSS セレクタ `.cards` と HTML 側の class 値が一致しているか見比べてください。',
    answer:
      '<div class="cards">\n  <div class="card">Task</div>\n</div>',
    explanation:
      'CSS は一致した class 名にしか適用されません。名前が少しでも違うと見た目は変わりません。',
    common_mistakes:
      '`.card` を変えてしまうと子要素側の意味までずれてしまいます。今回直すべきは親要素の class 名です。',
    display_order: 4619,
    themes: createHtmlCssTheme('HTML/CSS: レイアウト'),
  },
  {
    id: 'local-html-css-055',
    theme_id: 'local-html-css-form',
    title: 'label と input が結び付かないバグを直す',
    level: 3,
    type: 'normal',
    statement:
      '次のフォームではラベルをクリックしても入力欄にフォーカスしません。正しく動く HTML を書いてください。\n\n```html\n<label for="email">メールアドレス</label>\n<input id="mail" type="email">\n```',
    requirements:
      '`for` と `id` を一致させること\nフォーム全体ではなく必要部分だけを書けばよい',
    hint: 'ラベルと入力欄を結び付けるには、`label` の `for` と `input` の `id` を同じ値にします。',
    answer:
      '<label for="email">メールアドレス</label>\n<input id="email" type="email">',
    explanation:
      '`for` と `id` が一致していると、ラベル操作が入力欄に関連付き、使いやすさとアクセシビリティが上がります。',
    common_mistakes:
      '`name` をそろえてもラベルとの関連付けにはなりません。必要なのは `for` と `id` の一致です。',
    display_order: 4620,
    themes: createHtmlCssTheme('HTML/CSS: フォーム'),
  },
  {
    id: 'local-html-css-056',
    theme_id: 'local-html-css-responsive',
    title: 'メディアクエリ条件を逆にしているバグを直す',
    level: 3,
    type: 'normal',
    statement:
      'スマホ幅で縦並びにしたいのに、次の CSS だと PC 幅のときに縦並びになります。修正後の CSS を書いてください。\n\n```css\n@media (min-width: 768px) {\n  .cards {\n    flex-direction: column;\n  }\n}\n```',
    requirements:
      '`max-width: 768px` に修正すること\n`.cards` の指定は活かすこと',
    hint: '今回は「768px 以下」で切り替えたいので、幅条件の向きを見直します。',
    answer:
      '@media (max-width: 768px) {\n  .cards {\n    flex-direction: column;\n  }\n}',
    explanation:
      '`min-width` は指定幅以上で効く条件です。スマホ向けにしたいなら `max-width` を使って上限条件にします。',
    common_mistakes:
      'メディアクエリだけ直しても、元の `.cards` が Flexbox になっていないと縦並びは効きません。前提のレイアウト指定も合わせて確認します。',
    display_order: 4621,
    themes: createHtmlCssTheme('HTML/CSS: レスポンシブ'),
  },
]

export const LOCAL_GIT_GITHUB_PROBLEMS: ProblemRecord[] = [
  {
    id: 'local-git-github-001',
    theme_id: 'local-git-github-basic',
    title: '変更状況を確認するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '今どのファイルが変更されたか、追加されたかを確認したいです。Git で状態確認をするときのコマンドを書いてください。\n\ngit __________',
    requirements: 'コマンド名だけを書くこと',
    hint: '作業前後に一番よく見る基本コマンドです。',
    answer: 'status',
    explanation:
      '`git status` は、変更済みファイル、ステージ済みファイル、未追跡ファイルを確認するための基本コマンドです。',
    common_mistakes:
      '`log` は履歴確認、`diff` は差分確認です。現在の状態一覧を見るときは `status` を使います。',
    display_order: 5101,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-002',
    theme_id: 'local-git-github-basic',
    title: '特定ファイルをステージに追加するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`app.js` だけをコミット対象にしたいです。ステージへ追加するコマンドを書いてください。\n\ngit __________ app.js',
    requirements: 'コマンド名だけを書くこと',
    hint: 'コミット前に変更を登録する操作です。',
    answer: 'add',
    explanation:
      '`git add app.js` で、そのファイルの変更を次のコミット候補としてステージできます。',
    common_mistakes:
      '`commit` は記録、`push` は送信です。コミット対象に載せる段階では `add` を使います。',
    display_order: 5102,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-003',
    theme_id: 'local-git-github-basic',
    title: 'メッセージ付きでコミットするコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'ステージ済みの変更を、`"fix login"` というメッセージでコミットしたいです。空欄を埋めてください。\n\ngit commit __________ \"fix login\"',
    requirements: 'オプションだけを書くこと',
    hint: 'コミットメッセージを後ろに続けるときの短いオプションです。',
    answer: '-m',
    explanation:
      '`git commit -m "..."` で、コミットメッセージをその場で指定して保存できます。',
    common_mistakes:
      '`-a` は別の意味です。メッセージ指定では `-m` を使います。',
    display_order: 5103,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-004',
    theme_id: 'local-git-github-basic',
    title: 'main ブランチをリモートへ送るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'ローカルの `main` ブランチを `origin` に送信したいです。空欄を埋めてください。\n\ngit __________ origin main',
    requirements: 'コマンド名だけを書くこと',
    hint: 'ローカルから GitHub 側へ反映するときのコマンドです。',
    answer: 'push',
    explanation:
      '`git push origin main` で、ローカルの `main` ブランチの内容をリモートへ送れます。',
    common_mistakes:
      '`pull` は取り込む側です。送るときは `push` です。',
    display_order: 5104,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-005',
    theme_id: 'local-git-github-basic',
    title: 'リモートの変更を取り込むコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`origin` の `main` ブランチにある最新変更をローカルへ取り込みたいです。空欄を埋めてください。\n\ngit __________ origin main',
    requirements: 'コマンド名だけを書くこと',
    hint: 'GitHub 側の更新を自分の PC へ反映するときの基本コマンドです。',
    answer: 'pull',
    explanation:
      '`git pull origin main` で、リモートの `main` の変更を取得して現在のブランチへ取り込めます。',
    common_mistakes:
      '`fetch` は取得だけでマージしません。まとめて取り込むなら `pull` です。',
    display_order: 5105,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-006',
    theme_id: 'local-git-github-basic',
    title: 'リポジトリをコピーしてくるコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'GitHub のリポジトリ URL を使って、自分の PC にプロジェクト一式をコピーしたいです。空欄を埋めてください。\n\ngit __________ <URL>',
    requirements: 'コマンド名だけを書くこと',
    hint: '新しくプロジェクトを手元へ持ってくるときに使います。',
    answer: 'clone',
    explanation:
      '`git clone <URL>` で、リモートリポジトリをローカルに複製できます。',
    common_mistakes:
      '`init` は新規作成、`pull` は既存リポジトリの更新です。最初にコピーするときは `clone` です。',
    display_order: 5106,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-007',
    theme_id: 'local-git-github-basic',
    title: '新しい Git 管理を始めるコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'まだ Git 管理されていないフォルダで Git を使い始めたいです。空欄を埋めてください。\n\ngit __________',
    requirements: 'コマンド名だけを書くこと',
    hint: '新規プロジェクトで最初に 1 回だけ行うことが多いです。',
    answer: 'init',
    explanation:
      '`git init` で、そのフォルダを Git リポジトリとして初期化できます。',
    common_mistakes:
      '`clone` は既存リポジトリ取得用です。今あるフォルダを Git 管理にするなら `init` です。',
    display_order: 5107,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-008',
    theme_id: 'local-git-github-basic',
    title: 'コミット履歴を見るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'これまでのコミット履歴を一覧で確認したいです。空欄を埋めてください。\n\ngit __________',
    requirements: 'コマンド名だけを書くこと',
    hint: '誰がいつ何を記録したか追うときに見ます。',
    answer: 'log',
    explanation:
      '`git log` で、過去のコミット履歴を新しい順に確認できます。',
    common_mistakes:
      '`status` は現在の状態、`diff` は差分です。履歴一覧は `log` です。',
    display_order: 5108,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-009',
    theme_id: 'local-git-github-basic',
    title: 'すべての変更をまとめてステージするコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '変更したファイルをまとめてステージしたいです。空欄を埋めてください。\n\ngit add __________',
    requirements: '記号も含めてそのまま書くこと',
    hint: '現在のフォルダ配下の変更をまとめて追加するときによく使います。',
    answer: '.',
    explanation:
      '`git add .` で、現在のディレクトリ配下の変更をまとめてステージできます。',
    common_mistakes:
      '`*` を書くとシェル展開の影響を受けることがあります。基本練習では `.` を覚えるのが安全です。',
    display_order: 5109,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-010',
    theme_id: 'local-git-github-basic',
    title: '追跡したくないファイルを書く設定ファイル名',
    level: 1,
    type: 'fill_blank',
    statement:
      '`node_modules` や `.env` など、Git で管理したくないファイルを指定するときのファイル名を書いてください。\n\n__________',
    requirements: 'ファイル名をそのまま書くこと',
    hint: '先頭にドットが付くファイルです。',
    answer: '.gitignore',
    explanation:
      '`.gitignore` に書いたパターンは、Git の追跡対象から外しやすくなります。',
    common_mistakes:
      '`README.md` は説明用です。無視設定には `.gitignore` を使います。',
    display_order: 5110,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-011',
    theme_id: 'local-git-github-branch',
    title: '新しいブランチを作るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`feature/login` という新しいブランチを作りたいです。空欄を埋めてください。\n\ngit __________ feature/login',
    requirements: 'コマンド名だけを書くこと',
    hint: 'ブランチを作るだけの基本コマンドです。',
    answer: 'branch',
    explanation:
      '`git branch feature/login` で、新しいブランチを作成できます。',
    common_mistakes:
      '`switch` は移動、`merge` は統合です。作成だけなら `branch` です。',
    display_order: 5111,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-012',
    theme_id: 'local-git-github-branch',
    title: '既存ブランチへ移動するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'すでに存在する `feature/login` ブランチへ移動したいです。空欄を埋めてください。\n\ngit __________ feature/login',
    requirements: 'コマンド名だけを書くこと',
    hint: '最近の Git で、ブランチ移動によく使うコマンドです。',
    answer: 'switch',
    explanation:
      '`git switch feature/login` で、そのブランチへ移動できます。',
    common_mistakes:
      '`branch` は作成や一覧です。移動したいときは `switch` を使います。',
    display_order: 5112,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-013',
    theme_id: 'local-git-github-branch',
    title: 'ブランチ作成と移動を同時に行うオプション',
    level: 2,
    type: 'fill_blank',
    statement:
      '`feature/api` ブランチを作り、そのまま移動したいです。空欄を埋めてください。\n\ngit switch __________ feature/api',
    requirements: 'オプションをそのまま書くこと',
    hint: '`switch` で新規ブランチを作るときの短いオプションです。',
    answer: '-c',
    explanation:
      '`git switch -c feature/api` で、ブランチ作成と移動を一度に行えます。',
    common_mistakes:
      '`-d` は削除です。新規作成では `-c` を使います。',
    display_order: 5113,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-014',
    theme_id: 'local-git-github-branch',
    title: 'ブランチ一覧を見るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '今どんなブランチがあるか一覧を見たいです。空欄を埋めてください。\n\ngit __________',
    requirements: 'コマンド名だけを書くこと',
    hint: '新しいブランチを作るコマンドと同じ単語です。',
    answer: 'branch',
    explanation:
      '`git branch` だけを実行すると、ローカルブランチ一覧を確認できます。',
    common_mistakes:
      '`status` では現在ブランチ名は見えても一覧にはなりません。一覧は `branch` です。',
    display_order: 5114,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-015',
    theme_id: 'local-git-github-branch',
    title: 'feature ブランチを main に取り込むコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      '`main` ブランチにいる状態で、`feature/login` の変更を取り込みたいです。空欄を埋めてください。\n\ngit __________ feature/login',
    requirements: 'コマンド名だけを書くこと',
    hint: 'ブランチ同士を統合するときのコマンドです。',
    answer: 'merge',
    explanation:
      '`git merge feature/login` で、そのブランチの変更を現在のブランチへ取り込めます。',
    common_mistakes:
      '`pull` はリモート取り込みです。ローカルブランチ同士の統合は `merge` です。',
    display_order: 5115,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-016',
    theme_id: 'local-git-github-branch',
    title: '使い終わったブランチを削除するコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      'マージが終わった `feature/login` ブランチを削除したいです。空欄を埋めてください。\n\ngit branch __________ feature/login',
    requirements: 'オプションだけを書くこと',
    hint: '小文字 1 文字のオプションです。',
    answer: '-d',
    explanation:
      '`git branch -d feature/login` で、使い終わったローカルブランチを削除できます。',
    common_mistakes:
      '`-c` は作成です。削除では `-d` を使います。',
    display_order: 5116,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-017',
    theme_id: 'local-git-github-branch',
    title: 'main ブランチへ戻るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'feature ブランチでの作業を終えて、`main` に戻りたいです。空欄を埋めてください。\n\ngit switch __________',
    requirements: 'ブランチ名だけを書くこと',
    hint: '多くのプロジェクトで基準になるデフォルトブランチ名です。',
    answer: 'main',
    explanation:
      '`git switch main` で `main` ブランチへ戻れます。',
    common_mistakes:
      '`master` を使うプロジェクトもありますが、この問題では `main` を前提にしています。',
    display_order: 5117,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-018',
    theme_id: 'local-git-github-branch',
    title: '作業を分けるための仕組み名',
    level: 1,
    type: 'fill_blank',
    statement:
      '`main` に直接作業せず、機能ごとに作業を分けるときに使う Git の仕組み名を書いてください。\n\n__________',
    requirements: '英単語 1 つで答えること',
    hint: '`feature/login` のような名前を付けて使います。',
    answer: 'branch',
    explanation:
      'Git ではブランチを使うことで、機能追加や修正作業を本流から分けて進められます。',
    common_mistakes:
      '`repository` は保管場所全体です。作業の分岐単位は `branch` です。',
    display_order: 5118,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-019',
    theme_id: 'local-git-github-merge-conflict',
    title: 'コンフリクト先頭マーカー',
    level: 2,
    type: 'fill_blank',
    statement:
      'マージコンフリクトが起きたファイルの先頭側には、どの記号が表示されますか。空欄を埋めてください。\n\n__________ HEAD',
    requirements: '記号をそのまま書くこと',
    hint: '小なり記号が連続するマーカーです。',
    answer: '<<<<<<<',
    explanation:
      'コンフリクト箇所の自分側の変更は `<<<<<<< HEAD` から始まります。',
    common_mistakes:
      '`>>>>>>>` は相手側の終端です。先頭マーカーではありません。',
    display_order: 5119,
    themes: createGitGithubTheme('Git/GitHub: マージ / コンフリクト'),
  },
  {
    id: 'local-git-github-020',
    theme_id: 'local-git-github-merge-conflict',
    title: 'コンフリクト中央マーカー',
    level: 2,
    type: 'fill_blank',
    statement:
      'マージコンフリクトで、自分側と相手側の境目に表示される記号を書いてください。\n\n__________',
    requirements: '記号をそのまま書くこと',
    hint: 'イコール記号が連続します。',
    answer: '=======',
    explanation:
      '`=======` は、コンフリクト中の 2 つの変更を区切る境目として表示されます。',
    common_mistakes:
      '`<<<<<<<` と `>>>>>>>` は開始と終了です。中央の区切りは `=======` です。',
    display_order: 5120,
    themes: createGitGithubTheme('Git/GitHub: マージ / コンフリクト'),
  },
  {
    id: 'local-git-github-021',
    theme_id: 'local-git-github-merge-conflict',
    title: 'コンフリクト終端マーカー',
    level: 2,
    type: 'fill_blank',
    statement:
      'マージコンフリクトで相手側変更の終わりに表示される記号を書いてください。\n\n__________ feature/login',
    requirements: '記号をそのまま書くこと',
    hint: '大なり記号が連続するマーカーです。',
    answer: '>>>>>>>',
    explanation:
      '`>>>>>>> branch-name` は、相手側の変更ブロックの終端として表示されます。',
    common_mistakes:
      '`<<<<<<<` は開始側です。終端は `>>>>>>>` です。',
    display_order: 5121,
    themes: createGitGithubTheme('Git/GitHub: マージ / コンフリクト'),
  },
  {
    id: 'local-git-github-022',
    theme_id: 'local-git-github-merge-conflict',
    title: '一時退避するコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      'まだコミットしたくない変更を一時的に避けたいです。空欄を埋めてください。\n\ngit __________',
    requirements: 'コマンド名だけを書くこと',
    hint: '作業内容を一時的に棚へ置くイメージの機能です。',
    answer: 'stash',
    explanation:
      '`git stash` で、現在の変更を一時退避して作業ツリーをきれいな状態にできます。',
    common_mistakes:
      '`reset` や `restore` は取り消し寄りです。退避なら `stash` を使います。',
    display_order: 5122,
    themes: createGitGithubTheme('Git/GitHub: マージ / コンフリクト'),
  },
  {
    id: 'local-git-github-023',
    theme_id: 'local-git-github-merge-conflict',
    title: '退避した変更を戻すコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      '`git stash` した変更を取り出して戻したいです。空欄を埋めてください。\n\ngit stash __________',
    requirements: 'コマンド名だけを書くこと',
    hint: '退避したものを適用して、通常は一覧からも外れるコマンドです。',
    answer: 'pop',
    explanation:
      '`git stash pop` で、退避した変更を作業ツリーへ戻せます。',
    common_mistakes:
      '`push` は stash へ積む側です。戻すときは `pop` です。',
    display_order: 5123,
    themes: createGitGithubTheme('Git/GitHub: マージ / コンフリクト'),
  },
  {
    id: 'local-git-github-024',
    theme_id: 'local-git-github-merge-conflict',
    title: '差分を確認するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'コミット前に、どこが変更されたか行単位で確認したいです。空欄を埋めてください。\n\ngit __________',
    requirements: 'コマンド名だけを書くこと',
    hint: '追加行と削除行を見比べるときに使います。',
    answer: 'diff',
    explanation:
      '`git diff` で、作業ツリーとステージ、またはコミット間の差分を確認できます。',
    common_mistakes:
      '`status` は一覧だけで、具体的な差分内容までは出ません。',
    display_order: 5124,
    themes: createGitGithubTheme('Git/GitHub: マージ / コンフリクト'),
  },
  {
    id: 'local-git-github-025',
    theme_id: 'local-git-github-github-basic',
    title: '課題管理や相談を残す GitHub 機能名',
    level: 1,
    type: 'fill_blank',
    statement:
      '不具合報告やタスク整理を GitHub 上で残すときに使う機能名を書いてください。\n\nGitHub __________',
    requirements: '単語 1 つで答えること',
    hint: 'バグ報告や作業メモを積む場所です。',
    answer: 'Issues',
    explanation:
      'GitHub Issues は、バグ報告、改善案、タスク管理などに使われます。',
    common_mistakes:
      '`Pull Requests` はコード変更の提案です。課題管理の場では `Issues` を使います。',
    display_order: 5125,
    themes: createGitGithubTheme('Git/GitHub: GitHub基礎'),
  },
  {
    id: 'local-git-github-026',
    theme_id: 'local-git-github-pr',
    title: '変更を取り込んでもらうための GitHub 機能名',
    level: 1,
    type: 'fill_blank',
    statement:
      '自分の変更をレビューしてもらい、取り込んでもらうために GitHub で作成するものを書いてください。\n\nPull __________',
    requirements: '単語 1 つで答えること',
    hint: '略して PR と呼ばれます。',
    answer: 'Request',
    explanation:
      'Pull Request は、変更のレビュー依頼とマージ提案を兼ねた GitHub の基本機能です。',
    common_mistakes:
      '`Issue` は相談や課題管理です。変更提案は Pull Request です。',
    display_order: 5126,
    themes: createGitGithubTheme('Git/GitHub: Pull Request'),
  },
  {
    id: 'local-git-github-027',
    theme_id: 'local-git-github-github-basic',
    title: '他人のリポジトリを自分の GitHub へ複製する機能名',
    level: 2,
    type: 'fill_blank',
    statement:
      '他人の GitHub リポジトリを、自分のアカウント側へコピーして作業を始める機能名を書いてください。\n\n__________',
    requirements: '英単語 1 つで答えること',
    hint: 'OSS 参加でよく使う機能です。',
    answer: 'Fork',
    explanation:
      'Fork は、他人のリポジトリを自分の GitHub アカウント配下へ複製して作業する仕組みです。',
    common_mistakes:
      '`clone` はローカル PC への複製です。GitHub 上の自分の領域へコピーするのは `Fork` です。',
    display_order: 5127,
    themes: createGitGithubTheme('Git/GitHub: GitHub基礎'),
  },
  {
    id: 'local-git-github-028',
    theme_id: 'local-git-github-github-basic',
    title: 'リポジトリ説明を置く代表的なファイル名',
    level: 1,
    type: 'fill_blank',
    statement:
      'プロジェクト概要や起動方法を GitHub で最初に見せたいとき、よく使う代表的なファイル名を書いてください。\n\n__________',
    requirements: '拡張子も含めて書くこと',
    hint: 'GitHub のトップで自動表示されやすいファイルです。',
    answer: 'README.md',
    explanation:
      '`README.md` は、プロジェクト概要やセットアップ手順を書くための定番ファイルです。',
    common_mistakes:
      '`.gitignore` は無視設定用です。説明ファイルには `README.md` を使います。',
    display_order: 5128,
    themes: createGitGithubTheme('Git/GitHub: GitHub基礎'),
  },
  {
    id: 'local-git-github-029',
    theme_id: 'local-git-github-github-basic',
    title: 'リモートリポジトリのデフォルト名',
    level: 1,
    type: 'fill_blank',
    statement:
      'GitHub から `clone` したとき、元リポジトリに付いていることが多いデフォルトのリモート名を書いてください。\n\n__________',
    requirements: '単語 1 つで答えること',
    hint: '`git push origin main` の中にも出てくる名前です。',
    answer: 'origin',
    explanation:
      '`origin` は、clone 元のリモートリポジトリに対して自動で付くことが多い標準名です。',
    common_mistakes:
      '`main` はブランチ名です。リモート名ではありません。',
    display_order: 5129,
    themes: createGitGithubTheme('Git/GitHub: GitHub基礎'),
  },
  {
    id: 'local-git-github-030',
    theme_id: 'local-git-github-github-basic',
    title: 'リモート一覧を確認するコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      '今どのリモート先が登録されているか確認したいです。空欄を埋めてください。\n\ngit remote __________',
    requirements: 'オプションをそのまま書くこと',
    hint: 'URL つきで確認したいときによく使います。',
    answer: '-v',
    explanation:
      '`git remote -v` で、登録済みリモート名と URL を確認できます。',
    common_mistakes:
      '`-d` は削除です。表示では `-v` を使います。',
    display_order: 5130,
    themes: createGitGithubTheme('Git/GitHub: GitHub基礎'),
  },
  {
    id: 'local-git-github-031',
    theme_id: 'local-git-github-pr',
    title: 'PR を出す前の基本手順を書く',
    level: 3,
    type: 'normal',
    statement:
      'GitHub で Pull Request を出す前に、自分の PC で行う基本手順を 3 ステップで書いてください。',
    requirements:
      '変更をコミットする流れを含めること\nリモートへ push することを書くこと\n最後に GitHub で PR を作る流れにつながるように書くこと',
    hint: '作業ブランチで「add → commit → push」の流れを意識すると整理しやすいです。',
    answer:
      '1. 作業ブランチで変更を `git add` し、`git commit -m "..."` でコミットする。\n2. `git push origin ブランチ名` で GitHub へ送る。\n3. GitHub 上でそのブランチから Pull Request を作成する。',
    explanation:
      'PR は GitHub 上で作りますが、その前にローカル変更をコミットし、リモートへ送っておく必要があります。',
    common_mistakes:
      'ローカルでコミットしただけでは GitHub に変更は出ません。PR 前に `push` が必要です。',
    display_order: 5131,
    themes: createGitGithubTheme('Git/GitHub: Pull Request'),
  },
  {
    id: 'local-git-github-032',
    theme_id: 'local-git-github-branch',
    title: 'feature ブランチで作業して main に取り込む流れを書く',
    level: 3,
    type: 'normal',
    statement:
      '`main` に直接作業せず、`feature/login` のようなブランチで開発するときの基本的な流れを 4 ステップで書いてください。',
    requirements:
      'ブランチ作成または移動を含めること\nコミットを含めること\n最後に main へ取り込む流れを書くこと',
    hint: '作業前にブランチを切って、終わったら統合する流れです。',
    answer:
      '1. `main` から `git switch -c feature/login` で作業ブランチを作る。\n2. ファイルを編集して `git add` と `git commit` を行う。\n3. 必要なら `git push origin feature/login` で GitHub へ送る。\n4. 最後に `main` へマージするか Pull Request を作って取り込む。',
    explanation:
      '機能ごとにブランチを分けると、main を安定させたまま安全に作業できます。',
    common_mistakes:
      '最初から `main` で作業すると、未完成の変更が本流に混ざりやすくなります。',
    display_order: 5132,
    themes: createGitGithubTheme('Git/GitHub: ブランチ'),
  },
  {
    id: 'local-git-github-033',
    theme_id: 'local-git-github-pr',
    title: 'Pull Request の役割を書く',
    level: 3,
    type: 'normal',
    statement:
      'Pull Request は何のために使うのかを、初学者向けに 2 点で説明してください。',
    requirements:
      'レビュー依頼であることを書くこと\n変更を取り込む相談の場であることを書くこと',
    hint: '単なる送信ボタンではなく、確認と相談の場でもあります。',
    answer:
      '1. Pull Request は、自分の変更を他の人にレビューしてもらうために使います。\n2. その変更を main などへ取り込んでよいか確認しながら進めるための場でもあります。',
    explanation:
      'PR はコードを見てもらい、問題がないか確認した上で安全にマージするための重要な仕組みです。',
    common_mistakes:
      'PR を出しただけでは自動で本流へ入るわけではありません。レビューや確認を経てマージされます。',
    display_order: 5133,
    themes: createGitGithubTheme('Git/GitHub: Pull Request'),
  },
  {
    id: 'local-git-github-034',
    theme_id: 'local-git-github-merge-conflict',
    title: 'コンフリクトが起きたときの基本手順を書く',
    level: 3,
    type: 'normal',
    statement:
      'マージや pull の途中でコンフリクトが起きたときの基本対応を 3 ステップで書いてください。',
    requirements:
      'ファイルを手で直すことを書くこと\nコンフリクト記号を消すことに触れること\n最後に add と commit まで書くこと',
    hint: 'そのままでは終わらないので、内容確認と再登録が必要です。',
    answer:
      '1. コンフリクトしたファイルを開いて、残したい内容に手で修正し、`<<<<<<<` などの記号も消す。\n2. 修正後のファイルを `git add` する。\n3. 必要なコミットを行ってマージ作業を完了する。',
    explanation:
      'コンフリクトは Git が自動判断できなかった状態なので、最終内容を人が決めて再登録する必要があります。',
    common_mistakes:
      'コンフリクト記号を残したまま add すると、そのまま壊れたコードが保存されることがあります。',
    display_order: 5134,
    themes: createGitGithubTheme('Git/GitHub: マージ / コンフリクト'),
  },
  {
    id: 'local-git-github-035',
    theme_id: 'local-git-github-bugfix',
    title: '新規ファイルがコミットに入らないバグを直す',
    level: 2,
    type: 'normal',
    statement:
      '`login.js` を新しく作ったのに、コミット後も GitHub に反映されません。原因として考えやすいことと、直し方を 2 ステップで書いてください。',
    requirements:
      '未ステージの可能性に触れること\n`git add` を使うことを書くこと',
    hint: '新規ファイルは編集しただけではコミット対象に入らないことがあります。',
    answer:
      '1. `login.js` を `git add login.js` していない可能性がある。\n2. `git add login.js` を行ってから、もう一度コミットして push する。',
    explanation:
      'Git は、新規ファイルを自動でコミット対象にしません。まずステージへ追加する必要があります。',
    common_mistakes:
      'ファイルを保存しただけでコミットに含まれると思い込むと、このミスが起きやすいです。',
    display_order: 5135,
    themes: createGitGithubTheme('Git/GitHub: バグ修正'),
  },
  {
    id: 'local-git-github-036',
    theme_id: 'local-git-github-bugfix',
    title: 'push が rejected されたときの対処を書く',
    level: 3,
    type: 'normal',
    statement:
      '`git push origin main` をしたら rejected されました。リモート側に自分の持っていない更新があるときの基本対処を 3 ステップで書いてください。',
    requirements:
      'まず pull することに触れること\n競合があれば解消することを書くこと\n最後に再度 push することを書くこと',
    hint: '自分の変更を送る前に、先に相手側の更新を取り込んでそろえる必要があります。',
    answer:
      '1. まず `git pull origin main` でリモートの変更を取り込む。\n2. もしコンフリクトが起きたら内容を直して add / commit で解消する。\n3. その後でもう一度 `git push origin main` を行う。',
    explanation:
      'rejected は、リモート履歴の方が先に進んでいるときによく起きます。まず同期してから再送します。',
    common_mistakes:
      '理由を理解しないまま繰り返し `push` しても解決しません。先に差分を取り込みます。',
    display_order: 5136,
    themes: createGitGithubTheme('Git/GitHub: バグ修正'),
  },
  {
    id: 'local-git-github-037',
    theme_id: 'local-git-github-bugfix',
    title: 'コンフリクト記号を残したままにしないための修正手順',
    level: 3,
    type: 'normal',
    statement:
      'マージ後のファイルに `<<<<<<< HEAD` などの記号が残ってしまいました。どう直して作業を完了するかを 3 ステップで書いてください。',
    requirements:
      '不要な記号を消すことを書くこと\n残したいコードを決めることを書くこと\n最後に add と commit を行うことを書くこと',
    hint: 'Git の記号は最終コードではなく、判断待ちの印です。',
    answer:
      '1. ファイルを開いて、残すコードを決めながら `<<<<<<<` などの記号をすべて消す。\n2. 修正後のファイルを `git add` する。\n3. 必要なコミットをしてマージを完了する。',
    explanation:
      'コンフリクト記号は、Git が解決できなかった範囲を示すだけなので、そのまま残してはいけません。',
    common_mistakes:
      '記号だけ消して中身の整合を確認しないと、動かないコードになることがあります。',
    display_order: 5137,
    themes: createGitGithubTheme('Git/GitHub: バグ修正'),
  },
  {
    id: 'local-git-github-038',
    theme_id: 'local-git-github-github-basic',
    title: 'GitHub Actions の役割',
    level: 2,
    type: 'fill_blank',
    statement:
      'push や Pull Request をきっかけに、自動でテストやチェックを動かす GitHub の機能名を書いてください。\n\nGitHub __________',
    requirements: '単語をそのまま書くこと',
    hint: 'CI/CD の入口としてよく使われる機能です。',
    answer: 'Actions',
    explanation:
      'GitHub Actions は、テスト、lint、デプロイなどを自動実行できる仕組みです。',
    common_mistakes:
      '`Issues` や `Projects` では自動実行はできません。自動化は Actions の役割です。',
    display_order: 5138,
    themes: createGitGithubTheme('Git/GitHub: GitHub基礎'),
  },
  {
    id: 'local-git-github-039',
    theme_id: 'local-git-github-basic',
    title: 'fetch だけでリモート情報を取るコマンド',
    level: 2,
    type: 'fill_blank',
    statement:
      'マージはせず、まず `origin` の最新情報だけを取得したいです。空欄を埋めてください。\n\ngit __________ origin',
    requirements: 'コマンド名だけを書くこと',
    hint: '`pull` よりも 1 段階手前の操作です。',
    answer: 'fetch',
    explanation:
      '`git fetch origin` は、リモートの更新情報を取得するだけで、自分のブランチへはまだ取り込みません。',
    common_mistakes:
      '`pull` は取得と統合をまとめて行います。取得だけなら `fetch` です。',
    display_order: 5139,
    themes: createGitGithubTheme('Git/GitHub: 基本操作'),
  },
  {
    id: 'local-git-github-040',
    theme_id: 'local-git-github-pr',
    title: 'レビューコメントを受けた後の基本対応を書く',
    level: 3,
    type: 'normal',
    statement:
      'Pull Request にレビューコメントが付き、修正を求められました。基本対応を 3 ステップで書いてください。',
    requirements:
      'ローカルで修正することを書くこと\n修正後に commit / push することを書くこと\nPR 上で再確認してもらう流れにつなげること',
    hint: 'PR は作り直しではなく、同じブランチへ追加 push する流れが多いです。',
    answer:
      '1. 指摘内容をローカルの作業ブランチで修正する。\n2. 修正を `git add` と `git commit` で記録し、同じブランチへ `git push` する。\n3. 既存の Pull Request に修正内容が反映されるので、再確認してもらう。',
    explanation:
      'PR は 1 回出して終わりではなく、レビューを受けながら修正を積み増して完成度を上げていく場でもあります。',
    common_mistakes:
      '毎回 PR を作り直す必要はありません。同じブランチへ push すれば既存 PR に反映されることが多いです。',
    display_order: 5140,
    themes: createGitGithubTheme('Git/GitHub: Pull Request'),
  },
]

export const LOCAL_SQL_PROBLEMS: ProblemRecord[] = withLocalMetadata(
  SQL_PROBLEM_SEEDS.map(generatedProblem),
  6101,
  createSqlTheme
)

export const LOCAL_DOCKER_PROBLEMS: ProblemRecord[] = withLocalMetadata(
  DOCKER_PROBLEM_SEEDS.map(generatedProblem),
  7101,
  createDockerTheme
)

export const LOCAL_JAVASCRIPT_PROBLEMS: ProblemRecord[] = withLocalMetadata(
  JAVASCRIPT_PROBLEM_SEEDS.map(generatedProblem),
  8101,
  createJavaScriptTheme
)

export const LOCAL_TYPESCRIPT_PROBLEMS: ProblemRecord[] = withLocalMetadata(
  TYPESCRIPT_PROBLEM_SEEDS.map(generatedProblem),
  9101,
  createTypeScriptTheme
)

export const LOCAL_REACT_PROBLEMS: ProblemRecord[] = withLocalMetadata(
  REACT_PROBLEM_SEEDS.map(generatedProblem),
  10101,
  createReactTheme
)

export const LOCAL_LINUX_PROBLEMS: ProblemRecord[] = withLocalMetadata(
  LINUX_PROBLEM_SEEDS.map(generatedProblem),
  11101,
  createLinuxTheme
)

export function buildProblemKey(problem: Pick<ProblemRecord, 'title' | 'themes'>) {
  const theme = Array.isArray(problem.themes) ? problem.themes[0] : problem.themes
  const technologies = theme?.technologies
  const technology = Array.isArray(technologies) ? technologies[0] : technologies
  const technologySlug = technology?.slug ?? LEGACY_JAVA_TECHNOLOGY.slug
  const themeName = theme?.name ?? 'theme'
  return `${technologySlug}:${themeName}:${problem.title}`
}

const LOCAL_ADDITIONAL_PROBLEMS = [
  ...LOCAL_JAVA_PROBLEMS,
  ...LOCAL_SPRING_BOOT_PROBLEMS,
  ...LOCAL_AWS_PROBLEMS,
  ...LOCAL_FLUTTER_PROBLEMS,
  ...LOCAL_PHP_PROBLEMS,
  ...LOCAL_HTML_CSS_PROBLEMS,
  ...LOCAL_GIT_GITHUB_PROBLEMS,
  ...LOCAL_SQL_PROBLEMS,
  ...LOCAL_DOCKER_PROBLEMS,
  ...LOCAL_JAVASCRIPT_PROBLEMS,
  ...LOCAL_TYPESCRIPT_PROBLEMS,
  ...LOCAL_REACT_PROBLEMS,
  ...LOCAL_LINUX_PROBLEMS,
]

export function mergeWithLocalProblems(remoteProblems: ProblemRecord[]) {
  const existingKeys = new Set(remoteProblems.map(buildProblemKey))
  const localOnlyProblems = LOCAL_ADDITIONAL_PROBLEMS.filter(
    (problem) => !existingKeys.has(buildProblemKey(problem))
  )

  return [...remoteProblems, ...localOnlyProblems].sort(
    (a, b) => a.display_order - b.display_order
  )
}

export function compareProblemsByListOrder(
  a: Pick<ProblemRecord, 'level' | 'title'> & { display_order?: number | null },
  b: Pick<ProblemRecord, 'level' | 'title'> & { display_order?: number | null }
) {
  if (a.level !== b.level) return a.level - b.level

  const orderA = a.display_order ?? Number.MAX_SAFE_INTEGER
  const orderB = b.display_order ?? Number.MAX_SAFE_INTEGER
  if (orderA !== orderB) return orderA - orderB

  return a.title.localeCompare(b.title, 'ja')
}

export function findLocalProblem(problemId: string) {
  return LOCAL_ADDITIONAL_PROBLEMS.find((problem) => problem.id === problemId) ?? null
}

function readAllLocalRecords(): Record<string, LocalStudyRecord> {
  if (typeof window === 'undefined') return {}

  try {
    const raw = window.localStorage.getItem(LOCAL_RECORDS_KEY)
    if (!raw) return {}
    const parsed = JSON.parse(raw)
    return typeof parsed === 'object' && parsed !== null ? parsed : {}
  } catch {
    return {}
  }
}

function writeAllLocalRecords(records: Record<string, LocalStudyRecord>) {
  if (typeof window === 'undefined') return
  window.localStorage.setItem(LOCAL_RECORDS_KEY, JSON.stringify(records))
}

export function loadLocalStudyRecord(problemId: string) {
  return readAllLocalRecords()[problemId] ?? null
}

export function loadLocalStudyRecordSummaries(): Record<string, StudyRecordSummary> {
  const records = readAllLocalRecords()
  return Object.fromEntries(
    Object.entries(records).map(([problemId, record]) => [
      problemId,
      {
        problem_id: record.problem_id,
        self_assessment: record.self_assessment ?? '',
        is_weak: record.is_weak,
      },
    ])
  )
}

export function saveLocalStudyRecord(
  problemId: string,
  update: Partial<Omit<LocalStudyRecord, 'problem_id'>> & { user_code?: string }
) {
  const records = readAllLocalRecords()
  const previous = records[problemId]

  records[problemId] = {
    problem_id: problemId,
    user_code: update.user_code ?? previous?.user_code ?? '',
    self_assessment: update.self_assessment ?? previous?.self_assessment ?? null,
    is_weak: update.is_weak ?? previous?.is_weak ?? false,
    last_studied_at: update.last_studied_at ?? new Date().toISOString(),
  }

  writeAllLocalRecords(records)
  return records[problemId]
}
