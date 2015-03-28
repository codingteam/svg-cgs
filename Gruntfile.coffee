module.exports = (grunt) ->
  grunt.initConfig
    concat:
      all:
        src: ['node_modules/svgwm/test.css', 'test.css']
        dest: 'build/all.css'
    autoprefixer:
      all:
        src: 'build/all.css'
        dest: 'dist/all.css'
    coffee:
      compile:
        options:
          join: true
          bare: true
        files:
          'dist/all.js': ['node_modules/xpath-tools/*.coffee', 'node_modules/svgwm/main.coffee']
          'dist/patch.js': 'patch.coffee'
          'dist/main.js': 'main.coffee'
          'dist/test.js': 'test.coffee'
          'dist/loader.js': 'loader.coffee'
    copy:
      'lib-cgs':
        expand: true
        src: 'lib-cgs/**'
        dest: 'dist/'
      html:
        src: 'test.html'
        dest: 'dist/test.html'

  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-autoprefixer'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'

  grunt.registerTask 'default', [
    'concat:all'
    'autoprefixer:all'
    'coffee:compile'
    'copy:lib-cgs'
    'copy:html'
  ]
