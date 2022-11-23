fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
	"@es_extended/imports.lua",
	"@ox_lib/init.lua"
}
client_scripts {
	'config.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'client.lua',
}

server_scripts {
	'config.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'server.lua',
}

ui_page 'html/form.html'
files {
	'html/form.html',
	'html/img/seal.png',
	'html/img/document.jpg',
	'html/img/signature.png',
	'html/img/cursor.png',
	'html/css.css',
	'html/language_en.js',
	'html/language_gr.js',
	'html/language_br.js',
	'html/language_de.js',
	'html/language_fr.js',
	'html/script.js',
	'html/jquery-3.4.1.min.js',
}
