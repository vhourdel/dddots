function prmsg --description 'Build a Slack-ready summary for a GitHub PR'
    argparse h/help n/dry-run -- $argv
    or return

    if set -q _flag_help
        echo "Usage: prmsg [-n|--dry-run] <PR_URL|PR_NUMBER>" 1>&2
        return 0
    end

    if not command -q gh
        echo "Error: gh CLI is required." 1>&2
        return 1
    end

    if test (count $argv) -ne 1
        echo "Usage: prmsg [-n|--dry-run] <PR_URL|PR_NUMBER>" 1>&2
        return 1
    end

    set -l pr_ref $argv[1]
    set -l pr_data (gh pr view $pr_ref --json additions,deletions,title,files,url --jq '([.additions, .deletions, .title, .url] | @tsv), (.files[].path)' 2>/dev/null)
    if test $status -ne 0
        echo "Error: unable to retrieve PR data for '$pr_ref'." 1>&2
        return 1
    end

    if test (count $pr_data) -lt 1
        echo "Error: gh returned no data for '$pr_ref'." 1>&2
        return 1
    end

    set -l meta_fields (string split \t -- $pr_data[1])
    if test (count $meta_fields) -ne 4
        echo "Error: unexpected PR metadata format for '$pr_ref'." 1>&2
        return 1
    end

    set -l additions $meta_fields[1]
    set -l deletions $meta_fields[2]
    set -l title $meta_fields[3]
    set -l url $meta_fields[4]

    set -l size_score (math "$additions + $deletions")
    set -l size_emoji :one-liner:
    if test $size_score -gt 600
        set size_emoji :tshirt-xl:
    else if test $size_score -gt 300
        set size_emoji :l:
    else if test $size_score -gt 100
        set size_emoji :m:
    else if test $size_score -gt 30
        set size_emoji :s:
    else if test $size_score -gt 2
        set size_emoji :xs:
    end

    set -l language_emojis
    if test (count $pr_data) -gt 1
        for file_path in $pr_data[2..-1]
            set -l file (string lower -- $file_path)
            set -l language_emoji
            switch $file
                case '*.go'
                    set language_emoji :gopher:
                case '*.ts' '*.tsx'
                    set language_emoji :typescript:
                case '*.js' '*.jsx' '*.mjs' '*.cjs'
                    set language_emoji :js:
                case '*.py'
                    set language_emoji :python:
                case '*.rb'
                    set language_emoji :ruby:
                case '*.java'
                    set language_emoji :java:
                case '*.kt' '*.kts'
                    set language_emoji :kotlin:
                case '*.swift'
                    set language_emoji :swift:
                case '*.rs'
                    set language_emoji :rust:
                case '*.php'
                    set language_emoji :php:
                case '*.cs'
                    set language_emoji :csharp:
                case '*.sh' '*.bash' '*.zsh' '*.fish'
                    set language_emoji :shell:
                case '*.sql'
                    set language_emoji :postgres:
                case '*.tf' '*.tfvars'
                    set language_emoji :terraform:
                case '*.yml' '*.yaml'
                    set language_emoji :yaml:
                case '*.md' '*.mdx'
                    set language_emoji :markdown:
                case dockerfile
                    set language_emoji :docker:
            end

            if test -n "$language_emoji"
                if not contains -- $language_emoji $language_emojis
                    set language_emojis $language_emojis $language_emoji
                end
            end
        end
    end

    set -l language_blob (string join ' ' -- $language_emojis)
    set -l message ":pr: $size_emoji $language_blob [$title]($url)"

    if set -q _flag_n
        echo $message
        return 0
    end

    if command -q pbcopy
        printf '%s' "$message" | pbcopy
    else if command -q wl-copy
        printf '%s' "$message" | wl-copy
    else if command -q xclip
        printf '%s' "$message" | xclip -selection clipboard
    else if command -q xsel
        printf '%s' "$message" | xsel --clipboard --input
    else
        echo "Error: no clipboard tool found (pbcopy/wl-copy/xclip/xsel)." 1>&2
        return 1
    end
end
