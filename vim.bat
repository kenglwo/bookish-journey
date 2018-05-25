@echo off
cd ~
mkdir vimfiles\bundle
mkdir vimfiles\colors

rem Invoke-WebRequest -uri http://www.kobe-u.ac.jp/guid/link.html -outfile "C:\Usees\ueno\Desktop\a"
git clone https://github.com/Shougo/neobundle.vim ~/vimfiles/bundle/neobundle.vim

cd ~\vimfiles\colors
git clone https://github.com/vim-scripts/PaperColor.vim.git
move PaperColor.vim/colors/PaperColor.vim temp
rmdir /s PaperColor.vim
move temp PaperColor.vim

git clone https://github.com/tomasr/molokai.git
move molokai\colors\molokai.vim
rmdir /s molokai

git clone https://github.com/jacoborus/tender.vim.git
move tender.vim/colors/tender.vim temp
rmdir /s tender.vim
move temp tender.vim

git clone https://github.com/sjl/badwolf.git
move badwolf/colors/badwolf.vim badwolf.vim
rmdir /s badwolf

git clone https://github.com/hachy/eva01.vim.git
move eva01.vim/colors/eva01.vim temp
rmdir /s eva01.vim
move temp eva01.vim

git clone https://github.com/w0ng/vim-hybrid.git
move vim-hybrid/colors/hybrid.vim hybrid.vim
rmdir /s vim-hybrid

git clone https://github.com/nanotech/jellybeans.vim.git
move jellybeans.vim/colors/jellybeans.vim temp
rmdir /s jellybeans
move temp jellybeans.vim

git clone https://github.com/vim-scripts/Wombat.git
move Wombat/colors/wombat.vim wombat.vim
rmdir /s Wombat


