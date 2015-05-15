(require 'request)
(require 'json)

(defun play-rust ()
  "Play rust in playpen"
  (interactive)
  (post-rust-code t
	     (buffer-substring-no-properties (point-min) (point-max))
	     "2"
	     "beta"
	     nil))

(defun post-rust-code (run-p buf optimize version &optional asm-p)
  (request
   (if run-p "https://play.rust-lang.org/evaluate.json"
   "https://play.rust-lang.org/compile.json")
   ;; "http://httpbin.org/post"
   :type "POST"
   :data (json-encode `(("code" . ,buf)
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
