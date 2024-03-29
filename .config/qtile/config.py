# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Packages: alacritty feh dmenu dunst

from typing import List  # noqa: F401

from libqtile import bar, layout, widget, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = 'mod4'
terminal = 'alacritty'

colors = [
    ['#282c34', '#282c34'], # 0 - panel background
    ['#3d3f4b', '#434758'], # 1 - background for current screen tab
    ['#ffffff', '#ffffff'], # 2 - font color for group names
    ['#ff5555', '#ff5555'], # 3 - border line color for current tab
    ['#957DAD88', '#957DAD88'], # 4 - border line color for 'other tabs' and color for 'odd widgets'
    ['#3e477288', '#3e477288'], # 5 - color for the 'even widgets'
    ['#e1acff', '#e1acff'], # 6 - window name
    ['#ecbbfb', '#ecbbfb'], # 7 - backbround for inactive screens
    ['#ECE4C5', '#ECE4C5'], # 8 - cpu sensor
    ['#C1DBCC', '#C1DBCC'], # 9 - Nvidia sensor
    ['#999999', '#999999'], # 10 - inactive font color for group names
]

top_bar_color = '#11111150'

dmenu_normal = f'dmenu_run -i -fn "Cantarell-13" -nb "#111111" -nf "#957DAD" -p " > " -sb "#3e4772" -sf "#ffffff"'

"""
    Functions
"""

def open_nmtui():
    qtile.cmd_spawn(terminal + ' -e nmtui')

def open_pavo():
    qtile.cmd_spawn('pavucontrol')

def open_gnome_calendar():
    qtile.cmd_spawn('gnome-calendar')

def open_nvidia_setting():
    qtile.cmd_spawn('nvidia-settings')

def open_google_calendar():
    qtile.cmd_spawn('google-calendar-chrome')

"""
    Configurations
"""

keys = [
    # Custom Keys

    ## Next keyboard Layout
    Key([mod], 'space', lazy.widget['keyboardlayout'].next_keyboard(), 
        desc='Next keyboard layout.'),

    ## Spectacle screenshots
    Key([mod, 'shift'], 's', lazy.spawn('spectacle -bcr'),
        desc='Next keyboard layout.'),

    ## Terminal
    Key([mod], 'Return', lazy.spawn(terminal), 
        desc='Launch terminal'),
    ## Gnome terminal
    Key([mod, 'shift'], 'Return', lazy.spawn('gnome-terminal'), 
        desc='Launch Gnome terminal'),

    ## DMenu
    Key([mod], 'm', lazy.spawn(dmenu_normal), 
        desc='Normal dmenu'),

    ## Dolphin
    Key([mod], 's', lazy.spawn('dolphin'), 
        desc='Launch Dolphin'),

    ## Gmail
    Key([mod], 'x', lazy.spawn('gmail-chrome'), 
        desc='Launch Gmail'),

    ## Outlook
    Key([mod, 'shift'], 'x', lazy.spawn('outlook-chrome'), 
        desc='Launch Outlook'),

    ## Google Chrome browser
    Key([mod], 'a', lazy.spawn('google-chrome-stable'), 
        desc='Launch Google Chrome Stable'),

    ## Telegram
    Key([mod], 't', lazy.spawn('telegram-desktop'), 
        desc='Launch telegram'),

    ## Visual Studio Code
    Key([mod], 'c', lazy.spawn('code'), 
        desc='Launch Visual Studio Code'),

    ## Zoom meeting
    Key([mod], 'z', lazy.spawn('zoom'),
         desc='Launch Zoom'),

    ## Discord
    Key([mod], 'd', lazy.spawn('discord'),
         desc='Launch Discord'),

    ## Youtube Music - Chrome
    Key([mod], 'y', lazy.spawn('yt-music-chrome'),
         desc='Launch Youtube Music'),

    # Multimedia
    Key([], 'XF86AudioRaiseVolume', lazy.spawn('amixer -D pulse set Master 5%+')),
    Key([], 'XF86AudioLowerVolume', lazy.spawn('amixer -D pulse set Master 5%-')),
    Key([], 'XF86AudioMute', lazy.spawn('amixer -D pulse set Master Playback Switch toggle')),

    # Screen
    Key([], 'XF86MonBrightnessUp',   lazy.spawn('xbacklight -inc 5')),
    Key([], 'XF86MonBrightnessDown', lazy.spawn('xbacklight -dec 5')),

    # Switch between windows
    Key([mod], 'h', lazy.layout.left(), desc='Move focus to left'),
    Key([mod], 'l', lazy.layout.right(), desc='Move focus to right'),
    Key([mod], 'j', lazy.layout.down(), desc='Move focus down'),
    Key([mod], 'k', lazy.layout.up(), desc='Move focus up'),
    Key([mod, 'control'], 'space', lazy.layout.next(),
        desc='Move window focus to other window'),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, 'shift'], 'h', lazy.layout.shuffle_left(),
        desc='Move window to the left'),
    Key([mod, 'shift'], 'l', lazy.layout.shuffle_right(),
        desc='Move window to the right'),
    Key([mod, 'shift'], 'j', lazy.layout.shuffle_down(),
        desc='Move window down'),
    Key([mod, 'shift'], 'k', lazy.layout.shuffle_up(), desc='Move window up'),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, 'control'], 'h', lazy.layout.grow_left(),
        desc='Grow window to the left'),
    Key([mod, 'control'], 'l', lazy.layout.grow_right(),
        desc='Grow window to the right'),
    Key([mod, 'control'], 'j', lazy.layout.grow_down(),
        desc='Grow window down'),
    Key([mod, 'control'], 'k', lazy.layout.grow_up(), desc='Grow window up'),
    Key([mod], 'n', lazy.layout.normalize(), desc='Reset all window sizes'),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    # Key([mod, 'shift'], 'Return', lazy.layout.toggle_split(),
    #     desc='Toggle between split and unsplit sides of stack'),

    Key([mod], 'f', lazy.window.toggle_floating(),
        desc='Toggle between floating'
    ),

    # Toggle between different layouts as defined below
    Key([mod], 'Tab', lazy.next_layout(), desc='Toggle between layouts'),
    Key([mod], 'w', lazy.window.kill(), desc='Kill focused window'),

    Key([mod, 'control'], 'r', lazy.restart(), desc='Restart Qtile'),
    Key([mod, 'control'], 'q', lazy.shutdown(), desc='Shutdown Qtile'),
    Key([mod], 'r', lazy.spawncmd(),
        desc='Spawn a command using a prompt widget'),
]

group_size = 8
group_names = [
    (str(i), {
        'layout': 'columns'
        }
    ) for i in range(group_size)]

groups = [Group(name, label='',**kwargs) for name, kwargs in group_names]

for i, (name, kwargs) in enumerate(group_names, 1):
    # mod1 + letter of group = switch to group
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))
    
    # mod1 + shift + letter of group = switch to & move focused window to group
    keys.append(Key([mod, 'shift'], str(i), lazy.window.togroup(name)))

# Layouts

layout_theme = {
    'border_width': 1,
    'margin': 6,
    'border_focus': '#888888',
    'border_normal': '#4a4a4a'
}

widget_layout = {
    # 'background': '#282C34AA',
    # 'margin': 6
}

sep_prop = {
    'padding': 10,
    'linewidth': 0
}

layouts = [
    layout.Columns(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
    layout.TreeTab(**layout_theme),
    layout.floating.Floating(**layout_theme),

    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(**layout_theme),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
    
]

widget_defaults = dict(
    font='Open Sans',
    fontsize=12,
    padding=6,
)
extension_defaults = widget_defaults.copy()

def get_group_box_widget(): 
    return widget.GroupBox(
        **widget_layout,
        rounded=True,
        padding_y = 5,
        padding_x = 3,
        borderwidth = 3,
        fontsize=12,
        active = colors[2],
        inactive = colors[10],
        highlight_color = colors[1],
        highlight_method = "text",
        this_current_screen_border = colors[6],
        this_screen_border = colors [4],
        other_current_screen_border = colors[6],
        other_screen_border = colors[4],
        foreground = colors[2],
        background = '#22222280'
    )

def get_current_layout_icon():
    return widget.CurrentLayoutIcon(
        background = top_bar_color,
        scale = 0.5
    )

def get_window_name():
    return widget.WindowName(
        background = top_bar_color,
        foreground = colors[2],
        padding = 0,
        font='Open Sans'
    )

def get_spacer():
    return widget.Spacer(
        background = top_bar_color
    )

def get_system_tray_icons():
    return widget.Systray(
        **widget_layout,
        background = top_bar_color,
        icon_size=18
    )

def get_clock():
    return widget.Clock(
        **widget_layout,
        format=' %Y-%m-%d   [ %H:%M:%S ] ',
        mouse_callbacks={'Button1': open_google_calendar},
        background = colors[5],
        foreground = colors[2]
    )

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Sep(
                    linewidth=0,
                    padding=6,
                ),
                get_current_layout_icon(),
                get_window_name(),
                get_spacer(),
                get_group_box_widget(),
                get_spacer(),

                # System tray icons
                widget.TextBox(
                    text = '   ',
                    background = top_bar_color,
                    padding = 0,
                ),
                get_system_tray_icons(),
                widget.TextBox(
                    text = '   ',
                    background = top_bar_color,
                    padding = 0,
                ),

                # Colored Top Bar
                
                # Keyboard Layout
                widget.TextBox(
                    text = ' ',
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize = 15,
                    margin=0
                ),
                widget.KeyboardLayout(
                    **widget_layout,
                    configured_keyboards=['us', 'latam'],
                    foreground = colors[2],
                    background = colors[4],  
                ),
                widget.TextBox(
                    text = ' ',
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize = 15
                ),
                
                # Volumen
                widget.TextBox(
                    text = ' ',
                    mouse_callbacks={'Button3': open_pavo},
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize = 15
                ),
                widget.Volume(
                    **widget_layout,
                    mouse_callbacks={'Button3': open_pavo},
                    foreground = colors[2],
                    background = colors[4],
                ),
                widget.TextBox(
                    text = ' ',
                    mouse_callbacks={'Button3': open_pavo},
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize = 15
                ),

                # Backlight
                widget.TextBox(
                    text = ' ',
                    mouse_callbacks={'Button1': open_nvidia_setting},
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize=15,
                ),
                widget.Backlight(
                    **widget_layout,
                    format='{percent:1.0%}',
                    backlight_name='nvidia_0',
                    brightness_file='actual_brightness',
                    mouse_callbacks={'Button1': open_nvidia_setting},
                    foreground = colors[2],
                    background = colors[4],

                ),
                widget.TextBox(
                    text = ' ',
                    mouse_callbacks={'Button1': open_nvidia_setting},
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize=15,
                ),

                # Battery
                widget.TextBox(
                    text = ' ',
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize=16,
                ),

                widget.Battery(
                    **widget_layout,
                    format='{percent:2.0%} {char}',
                    charge_char=u'↑',
                    discharge_char = u'↓',
                    update_delay = 5,
                    foreground = colors[2],
                    background = colors[4],
                ),
                widget.TextBox(
                    text = ' ',
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize=16,
                ),

                # Networking
                widget.Net(
                    interface='wlp0s20f3',
                    mouse_callbacks={'Button1': open_nmtui},
                    format=' ',
                    update_interval=3,
                    max_chars=17,
                    padding=0,
                    foreground = colors[2],
                    background = colors[4],
                ),
                widget.TextBox(
                    text = '  ',
                    foreground = colors[2],
                    background = colors[4],
                    padding = 0,
                    fontsize=16,
                ),
                
                # Clock
                get_clock(),

                # Logout
                widget.QuickExit(
                    **widget_layout,
                    default_text=' Scarlet   ',
                    countdown_format=' Scarlet {} '
                ),
                
                widget.Sep(
                    linewidth=0,
                    padding=6,
                ),
            ],
            30,
            background = top_bar_color,
            opacity = 1,
            margin=5,
        ),
    ),
    Screen (
        top=bar.Bar(
            [
                widget.Sep(
                    linewidth=0,
                    padding=6,
                ),
                get_current_layout_icon(),
                get_window_name(),
                get_spacer(),
                get_group_box_widget(),
                get_spacer(),
                get_clock(),
                widget.Sep(
                    linewidth=0,
                    padding=6,
                ),
            ],
            30
        )
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], 'Button1', lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], 'Button3', lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], 'Button2', lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = 'smart'
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = 'LG3D'
