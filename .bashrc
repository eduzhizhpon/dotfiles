#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# ==================================================
# PS1 Content
# ==================================================
 
# Function to get current git branch ⑆
parse_git_branch() {
    if [[ -d ./.git ]]; then
	    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/  [\1]/'
    fi
}

# PS1='$(parse_git_branch) \u@\h \W \$' 
if [ "$color_prompt" = yes ]; then
	PS1='\[\033[32m\]\W\[\033[33m\]$(parse_git_branch)\[\033[00m\]  '
else
	PS1='\W$(parse_git_branch) \$ '
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

[[ -f ~/.core_rc ]] && source ~/.core_rc
