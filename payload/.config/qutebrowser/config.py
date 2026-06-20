config.load_autoconfig()

import catppuccin
catppuccin.setup(c, 'mocha', True)

c.auto_save.session = True
c.tabs.show = 'multiple'
c.tabs.position = 'top'
c.tabs.padding = {'top': 4, 'bottom': 4, 'left': 8, 'right': 8}
c.statusbar.show = 'in-mode'
c.content.blocking.method = 'both'

c.fonts.default_size = '11pt'
c.fonts.web.size.default = 16
c.fonts.completion.entry = '11pt Berkeley Mono'
c.fonts.statusbar = '11pt Berkeley Mono'
c.fonts.tabs.selected = '11pt Berkeley Mono'
c.fonts.tabs.unselected = '11pt Berkeley Mono'

c.completion.height = '40%'
c.completion.shrink = True
c.downloads.position = 'bottom'

c.url.default_page = 'https://start.duckduckgo.com/'
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'g': 'https://www.google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'aw': 'https://wiki.archlinux.org/?search={}',
}

config.bind(',m', 'hint links spawn mpv {hint-url}')
config.bind(',y', 'yank url')
config.bind(',Y', 'yank selection')
