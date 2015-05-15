(require 'request)
(require 'json)

(defvar rust-version "beta")		;default version
(defvar optimize "2")			;default optimization

(defun playpen-evaluate ()
  "Evaluate rust code."
  (interactive)
  (message "Connecting to playpen...")
  (post-rust-code t "2" rust-version nil))

(defun playpen-generate-asm ()
  "Generate asm code."
  (interactive)
  (message "Connecting to playpen...")
  (post-rust-code nil "0" rust-version t))

(defun playpen-generate-ir ()
  "Generate IR code."
  (interactive)
  (message "Connecting to playpen...")
  (post-rust-code nil "0" rust-version nil))

(defun post-rust-code (run-p optimize version &optional asm-p)
  "Post current buffer to rust playpen."
  (request
   (if run-p "https://play.rust-lang.org/evaluate.json"
   "https://play.rust-lang.org/compile.json")
   ;; "http://httpbin.org/post"
   :type "POST"
   :data (json-encode `(("code" . ,(buffer-substring-no-properties (point-min) (point-max)))
			("optimize" . ,optimize)
			("version" . ,version)
			("highlight" . ,json-false)
			("emit" . ,(if asm-p "asm" "llvm-ir"))))
   :headers '(("Content-Type" . "application/json"))
   :parser 'json-read
   :success (function*
	     (lambda (&key data &allow-other-keys)
	       ;; (message "Result:%s" (assoc-default 'json data))
	       (progn (switch-to-buffer-other-window "*Result*")
	       	      (insert (format "// <Version:%s Optimize:%s Time:%s>\n%s"
	       			      "beta"
	       			      "2"
	       			      (current-time-string)
	       			      (assoc-default 'result data))))
	       )))
  )

(define-minor-mode playpen-mode
  :lighter " playpen"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map (kbd "C-c C-c e") 'playpen-evaluate)
	    (define-key map (kbd "C-c C-c a") 'playpen-generate-asm)
	    (define-key map (kbd "C-c C-c i") 'playpen-generate-ir)
	    map))

;; auto load
(add-hook 'rust-mode-hook 'playpen-mode)

(provide 'playpen-mode)
