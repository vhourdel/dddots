function openprweb --description "Open PR creation UI for current branch on web-ui"
    set -l BRANCH (git rev-parse --abbrev-ref HEAD)
    open "https://github.com/DataDog/web-ui/compare/preprod...$BRANCH"
end
