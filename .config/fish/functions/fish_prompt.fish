function fish_prompt
    set -l __last_command_exit_status $status

    if set -q -g __fish_prompt_has_rendered
        echo
    else
        set -g __fish_prompt_has_rendered 1
    end

    if not set -q -g __fish_arrow_functions_defined
        set -g __fish_arrow_functions_defined
        function _git_branch_name
            set -l branch (git symbolic-ref --quiet HEAD 2>/dev/null)
            if set -q branch[1]
                echo (string replace -r '^refs/heads/' '' $branch)
            else
                echo (git rev-parse --short HEAD 2>/dev/null)
            end
        end

        function _is_git_dirty
            not command git diff-index --cached --quiet HEAD -- &>/dev/null
            or not command git diff --no-ext-diff --quiet --exit-code &>/dev/null
        end

        function _git_prompt_status_summary
            set -l staged 0
            set -l modified 0
            set -l untracked 0
            set -l conflicts 0
            set -l ahead 0
            set -l behind 0

            for line in (git status --porcelain=v2 --branch 2>/dev/null)
                if string match -qr '^# branch\.ab ' -- $line
                    set -l parts (string split ' ' -- $line)
                    set ahead (string replace '+' '' -- $parts[3])
                    set behind (string replace '-' '' -- $parts[4])
                else if string match -qr '^[12] ' -- $line
                    set -l parts (string split ' ' -- $line)
                    set -l xy $parts[2]
                    set -l index_state (string sub --start 1 --length 1 -- $xy)
                    set -l worktree_state (string sub --start 2 --length 1 -- $xy)

                    if test $index_state != '.'
                        set staged (math $staged + 1)
                    end

                    if test $worktree_state != '.'
                        set modified (math $modified + 1)
                    end
                else if string match -qr '^u ' -- $line
                    set conflicts (math $conflicts + 1)
                else if string match -qr '^\? ' -- $line
                    set untracked (math $untracked + 1)
                end
            end

            set -l segments
            if test $staged -gt 0
                set -a segments "●$staged"
            end

            if test $modified -gt 0
                set -a segments "✱$modified"
            end

            if test $untracked -gt 0
                set -a segments "✚$untracked"
            end

            if test $conflicts -gt 0
                set -a segments "✖$conflicts"
            end

            if test $ahead -gt 0
                set -a segments "↑$ahead"
            end

            if test $behind -gt 0
                set -a segments "↓$behind"
            end

            if test (count $segments) -gt 0
                string join ' ' -- $segments
            end
        end

        function _is_git_repo
            type -q git
            or return 1
            git rev-parse --git-dir >/dev/null 2>&1
        end

        function _hg_branch_name
            echo (hg branch 2>/dev/null)
        end

        function _is_hg_dirty
            set -l stat (hg status -mard 2>/dev/null)
            test -n "$stat"
        end

        function _is_hg_repo
            fish_print_hg_root >/dev/null
        end

        function _repo_branch_name
            _$argv[1]_branch_name
        end

        function _is_repo_dirty
            _is_$argv[1]_dirty
        end

        function _repo_type
            if _is_hg_repo
                echo hg
                return 0
            else if _is_git_repo
                echo git
                return 0
            end
            return 1
        end
    end

    set -l cyan (set_color -o cyan)
    set -l yellow (set_color -o yellow)
    set -l red (set_color -o red)
    set -l green (set_color -o green)
    set -l blue (set_color -o blue)
    set -l normal (set_color normal)

    set -l arrow_color "$green"
    if test $__last_command_exit_status != 0
        set arrow_color "$red"
    end

    set -l arrow "$arrow_color➜ "
    if fish_is_root_user
        set arrow "$arrow_color# "
    end

    set -l cwd $cyan(prompt_pwd | path basename)

    set -l repo_info
    if set -l repo_type (_repo_type)
        set -l repo_branch $red(_repo_branch_name $repo_type)
        set repo_info "$blue $repo_type:($repo_branch"

        if test $repo_type = git
            set -l git_status (_git_prompt_status_summary)
            if test -n "$git_status"
                set repo_info "$repo_info $yellow$git_status"
            end
        else if _is_repo_dirty $repo_type
            set repo_info "$repo_info $yellow✗"
        end

        set repo_info "$repo_info$blue)"
    end

    echo -n -s $cwd $repo_info $normal
    echo
    if test $__last_command_exit_status != 0
        echo -n -s $red $__last_command_exit_status ' '
    end
    echo -n -s $arrow $normal ' '
end
