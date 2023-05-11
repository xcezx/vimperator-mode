;;; vimperator-mode.el --- Major mode for editing Vimperator configuration files.

;; Copyright (C) 2009 xcezx

;; Author: xcezx
;; Keywords: vimperator

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This is a major mode for editing Vimperator configuration files.

;;; Installation:

;; (autoload 'vimperator-mode "vimperator-mode"
;;   "Major mode for editing Vimperator configuration files.")
;; (add-to-list 'auto-mode-alist '("\\.vimperatorrc$" . vimperator-mode))

;;; Code:

(require 'font-lock)
(eval-when-compile
  (require 'regexp-opt))

(defconst vimperator-mode-version "0.1"
  "Vimperator Mode version number.")

;; Custom variables

(defgroup vimperator nil
  "Major mode for editing Vimperator configuration files."
  :group 'languages)

(defcustom vimperator-mode-hook nil
  "Hook run when entering Vimperator mode."
  :type 'hook
  :group 'vimperator)

;; Custom Faces

(defface vimperator-command-kwds-face
  '((t :inherit font-lock-keyword-face))
  "Face to use for Vimperator commands."
  :group 'vimperator)

(defface vimperator-auto-command-kwds-face
  '((t :inherit font-lock-keyword-face))
  "Face to use for Vimperator auto commands."
  :group 'vimperator)

(defface vimperator-auto-event-kwds-face
  '((t :inherit font-lock-keyword-face))
  "Face to use for Vimperator auto events."
  :group 'vimperator)

(defface vimperator-option-kwds-face
  '((t :inherit font-lock-variable-name-face))
  "Face to use for Vimperator options."
  :group 'vimperator)

;; Local variables

(defvar vimperator-mode-syntax-table nil
  "Syntax table used in `vimperator-mode'.")

(if vimperator-mode-syntax-table
    ()
  (setq vimperator-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\" "< b" vimperator-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" vimperator-mode-syntax-table))

(defvar vimperator-mode-map ()
  "Keymap used in vimperator-mode buffers.")

(if vimperator-mode-map
    ()
  (setq vimperator-mode-map (make-sparse-keymap)))

;; Constants

(defconst vimperator-command-kwds
  '("abbreviate" "abclear" "addons" "bNext" "buffer" "back" "bdelete"
    "beep" "bfirst" "blast" "bmark" "bmarks" "bnext" "bprevious"
    "brewind" "bufdo" "buffers" "bunload" "bwipeout" "cabbrev"
    "cabclear" "cd" "chdir" "cmap" "cmapclear" "cnoremap"
    "colorscheme" "command" "comclear" "cunmap" "cunabbrev"
    "delbmarks" "delcommand" "delmarks" "delmacros" "delqmarks"
    "delstyle" "dialog" "dl" "doautocmd" "doautoall" "downloads"
    "echo" "echoerr" "echomsg" "emenu" "execute" "extadd" "extdisable"
    "extdelete" "extenable" "extensions" "extoptions" "extpreferences"
    "exusage" "files" "finish" "forward" "frameonly" "fw" "help"
    "helpall" "hardcopy" "highlight" "history" "hs" "iabbrev"
    "iabclear" "imap" "imapclear" "inoremap" "iunmap" "iunabbrev"
    "javascript" "js" "jumps" "keepalt" "let" "loadplugins" "lpl" "ls"
    "mark" "macros" "map" "mapclear" "marks" "messages" "messclear"
    "mkvimperatorrc" "nmap" "nmapclear" "nnoremap" "noremap"
    "nohlsearch" "normal" "nunmap" "open" "optionusage" "pageinfo"
    "pagestyle" "pas" "play" "preferences" "prefs" "pwd" "quit" "qall"
    "qmark" "qmarks" "quitall" "redraw" "reload" "reloadall" "restart"
    "run" "runtime" "sanitize" "saveas" "sbar" "sbopen" "sbclose"
    "scriptnames" "set" "setglobal" "setlocal" "sidebar" "silent"
    "source" "stop" "stopall" "style" "stydisable" "styledisable"
    "styenable" "styleenable" "stytoggle" "styletoggle" "tNext"
    "topen" "tab" "tabattach" "tabNext" "tabclose" "tabdo" "tabdetach"
    "tabduplicate" "tabfirst" "tablast" "tabmove" "tabnext" "tabnew"
    "tabonly" "tabopen" "tabprevious" "tabrewind" "tabs" "tbhide"
    "tbshow" "tbtoggle" "time" "tnext" "toolbarhide" "toolbarshow"
    "toolbartoggle" "tprevious" "undo" "unabbreviate" "undoall"
    "unlet" "unmap" "verbose" "version" "viewsource" "viusage" "vmap"
    "vmapclear" "vnoremap" "vunmap" "write" "wclose" "winopen"
    "winclose" "window" "winonly" "wopen" "wq" "wqall" "xall" "zoom"))

(defconst vimperator-command-short-kwds
  '("ab" "ab" "addo" "bN" "b" "ba" "bd" "bf" "bl" "bma" "bmarks" "bn"
  "bp" "br" "bufd" "buffers" "bun" "bw" "ca" "cabc" "chd" "cm" "cmapc"
  "cno" "colo" "com" "comc" "cu" "cuna" "delbm" "delc" "delm" "delmac"
  "delqm" "dels" "dia" "do" "doautoa" "downl" "ec" "echoe" "echom"
  "em" "exe" "exta" "extd" "extde" "exte" "extens" "exto" "extp" "exu"
  "fini" "fo" "frameo" "h" "helpa" "ha" "hi" "hist" "ia" "iabc" "im"
  "imapc" "ino" "iu" "iuna" "javas" "ju" "keepa" "ma" "mapc" "mes"
  "messc" "mkv" "nm" "nmapc" "nno" "no" "noh" "norm" "nu" "o"
  "optionu" "pa" "pagest" "pl" "pref" "pw" "q" "qa" "qma" "quita" "re"
  "re" "reloada" "res" "runt" "sa" "sav" "sb" "sb" "sbcl" "scrip" "se"
  "setg" "setl" "sideb" "sil" "so" "st" "stopa" "sty" "styd" "styled"
  "stye" "stylee" "styt" "stylet" "tN" "t" "taba" "tabN" "tabc" "tabd"
  "tabde" "tabdu" "tabfir" "tabl" "tabm" "tabn" "tabo" "tabp" "tabr"
  "tbh" "tbs" "tbt" "tn" "toolbarh" "toolbars" "toolbart" "tp" "u"
  "una" "undoa" "unl" "unm" "verb" "ve" "vie" "viu" "vm" "vmap" "vno"
  "vu" "w" "wc" "win" "winc" "wind" "winon" "wo" "wqa" "xa" "zo"))

(defconst vimperator-auto-command-kwds
  '("au" "autocmd"))

(defconst vimperator-auto-event-kwds
  '("BookmarkAdd" "ColorSheme" "DOMLoad" "DownloadPost" "Fullscreen"
  "LocationChange" "PageLoadPre" "PageLoad" "PrivateMode" "Sanitize"
  "ShellCmdPost" "VimperatorEnter" "VimperatorLeavePre"
  "VimperatorLeave"))

(defconst vimperator-option-kwds
  '("act" "activate" "cd" "cdpath" "complete" "cpt" "defsearch" "ds"
  "editor" "eht" "ei" "enc" "encoding" "eventignore"
  "extendedhinttags" "fenc" "fileencoding" "fh" "followhints" "go"
  "guioptions" "helpfile" "hf" "hi" "hin" "hintinputs" "hintmatching"
  "hinttags" "hinttimeout" "history" "hm" "ht" "hto" "laststatus" "ls"
  "maxitems" "messages" "msgs" "newtab" "nextpattern" "pa" "pageinfo"
  "popups" "pps" "previouspattern" "rtp" "runtimepath" "si"
  "sanitizeitems" "sts" "sanitizetimespan" "scr" "scroll" "sh" "shcf"
  "shell" "shellcmdflag" "showstatuslinks" "showtabline" "ssli" "stal"
  "suggestengines" "titlestring" "urlseparator" "vbs" "verbose" "wic"
  "wig" "wildcase" "wildignore" "wildmode" "wildoptions" "wim" "wop"
  "wordseparators" "wsp"))

(defconst vimperator-keywords
  (regexp-opt
   (append vimperator-command-kwds
           vimperator-command-short-kwds
           vimperator-auto-command-kwds
           vimperator-auto-event-kwds
           vimperator-option-kwds) 'words))

(defconst vimperator-font-lock-keywords
  (list
   `(,(concat "\\(^[ \t]*\\|:\\)" (regexp-opt vimperator-command-kwds 'words) "!?") 0 'vimperator-command-kwds-face)
   `(,(concat "\\(^[ \t]*\\|:\\)" (regexp-opt vimperator-command-short-kwds 'words) "!?") 0 'vimperator-command-kwds-face)
   `(,(regexp-opt vimperator-auto-command-kwds 'words) 0 'vimperator-auto-command-kwds-face)
   `(,(regexp-opt vimperator-auto-event-kwds 'words) 0 'vimperator-auto-event-kwds-face)
   `(,(regexp-opt vimperator-option-kwds 'words) 0 'vimperator-option-kwds-face))
  "Subdued level highlighting for Vimperator mode.")

;;;;

;;;###autoload
(defun vimperator-mode ()
  "Major mode for editing Vimperator configuration files.

\\{vimperator-mode-map}"

  (interactive)
  (kill-all-local-variables)

  (set-syntax-table vimperator-mode-syntax-table)

  (set (make-local-variable 'font-lock-defaults)
       '(vimperator-font-lock-keywords))

  (set (make-local-variable 'comment-start) "\" ")
  (set (make-local-variable 'comment-end) "")

  (use-local-map vimperator-mode-map)

  (setq major-mode 'vimperator-mode
        mode-name "Vimperator")

  (run-mode-hooks 'vimperator-mode-hook))

(provide 'vimperator-mode)
