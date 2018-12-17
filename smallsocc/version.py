VERSION_MAJOR = '0'
VERSION_MINOR = '2'
VERSION_PATCH = '1'
VERSION_HASH  = '860c60d'

VERSION_FULL = '{!s}.{!s}'.format(VERSION_MAJOR, VERSION_MINOR) + \
               ('.{!s}'.format(VERSION_PATCH) if VERSION_PATCH != '0' else '') + \
               ('-{!s}'.format(VERSION_HASH) if VERSION_HASH != '' else '')
