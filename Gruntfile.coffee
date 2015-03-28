module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        options:
          join: true
        files:
          'all.js': '*.coffee'

  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask('default', ['coffee:compile']);
