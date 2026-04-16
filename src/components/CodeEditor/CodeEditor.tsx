'use client'

import dynamic from 'next/dynamic'
import { indentWithTab } from '@codemirror/commands'
import { java } from '@codemirror/lang-java'
import { indentUnit } from '@codemirror/language'
import { EditorState, Prec } from '@codemirror/state'
import { oneDark } from '@codemirror/theme-one-dark'
import { EditorView, keymap, placeholder } from '@codemirror/view'

const CodeMirror = dynamic(() => import('@uiw/react-codemirror'), {
  ssr: false,
})

const editorTheme = EditorView.theme({
  '&': {
    backgroundColor: '#1e1e1e',
    border: '1px solid var(--border)',
    borderRadius: 'calc(var(--radius) / 2)',
    fontSize: '0.95rem',
    overflow: 'hidden',
  },
  '&.cm-focused': {
    outline: 'none',
    borderColor: 'var(--primary)',
  },
  '.cm-scroller': {
    fontFamily: 'var(--font-mono)',
    minHeight: '400px',
  },
  '.cm-content': {
    padding: '1rem',
  },
  '.cm-line': {
    padding: '0 0 0 0.25rem',
  },
  '.cm-gutters': {
    backgroundColor: '#181818',
    color: '#64748b',
    border: 'none',
    minHeight: '400px',
  },
  '.cm-activeLine': {
    backgroundColor: 'rgba(148, 163, 184, 0.08)',
  },
  '.cm-activeLineGutter': {
    backgroundColor: 'rgba(148, 163, 184, 0.08)',
  },
  '.cm-cursor': {
    borderLeftColor: '#60a5fa',
  },
  '.cm-selectionBackground, ::selection': {
    backgroundColor: 'rgba(96, 165, 250, 0.28) !important',
  },
})

type CodeEditorProps = {
  value: string
  onChange: (value: string) => void
  placeholderText: string
  language?: 'java' | 'plain'
  minHeight?: number
}

const INDENT = '    '

const smartEnter = (view: EditorView) => {
  const selection = view.state.selection.main
  if (!selection.empty) return false

  const line = view.state.doc.lineAt(selection.from)
  const cursorOffset = selection.from - line.from
  const beforeCursor = line.text.slice(0, cursorOffset)
  const afterCursor = line.text.slice(cursorOffset)
  const baseIndent = line.text.match(/^\s*/)?.[0] ?? ''
  const shouldIndentDeeper = beforeCursor.trimEnd().endsWith('{')
  const closesBlockImmediately = /^\s*}/.test(afterCursor)

  if (shouldIndentDeeper && closesBlockImmediately) {
    const insertText = `\n${baseIndent}${INDENT}\n${baseIndent}`
    const anchor = selection.from + 1 + baseIndent.length + INDENT.length

    view.dispatch({
      changes: { from: selection.from, to: selection.to, insert: insertText },
      selection: { anchor },
      userEvent: 'input',
    })
    return true
  }

  const nextIndent = shouldIndentDeeper ? `${baseIndent}${INDENT}` : baseIndent
  view.dispatch({
    changes: { from: selection.from, to: selection.to, insert: `\n${nextIndent}` },
    selection: { anchor: selection.from + 1 + nextIndent.length },
    userEvent: 'input',
  })
  return true
}

export default function CodeEditor({
  value,
  onChange,
  placeholderText,
  language = 'plain',
  minHeight = 400,
}: CodeEditorProps) {
  const extensions = [
    editorTheme,
    EditorState.tabSize.of(4),
    indentUnit.of(INDENT),
    Prec.highest(
      keymap.of([
        { key: 'Enter', run: smartEnter },
        indentWithTab,
      ])
    ),
    placeholder(placeholderText),
  ]

  if (language === 'java') {
    extensions.push(java())
  }

  return (
    <CodeMirror
      value={value}
      height={`${minHeight}px`}
      theme={oneDark}
      extensions={extensions}
      onChange={onChange}
      basicSetup={{
        lineNumbers: true,
        foldGutter: false,
        highlightActiveLineGutter: true,
        highlightActiveLine: true,
        indentOnInput: true,
        bracketMatching: true,
        closeBrackets: true,
        autocompletion: false,
        syntaxHighlighting: true,
      }}
    />
  )
}
