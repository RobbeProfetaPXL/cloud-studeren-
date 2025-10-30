// karma.conf.js
module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage'),
      require('karma-junit-reporter'),
      require('@angular-devkit/build-angular/plugins/karma')
    ],
    client: {
      jasmine: { /* opties indien gewenst */ },
      clearContext: false
    },
    jasmineHtmlReporter: { suppressAll: true },
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage/frontend'),
      subdir: '.',
      reporters: [{ type: 'html' }, { type: 'text-summary' }]
    },

    // Gebruik de custom headless Chrome launcher
    browsers: ['ChromeHeadlessCI'],
    customLaunchers: {
      ChromeHeadlessCI: {
        base: 'ChromeHeadless',               // <-- FIX (niet 'ChromeHeadlessCI')
        flags: [
          '--headless=new',
          '--no-sandbox',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-gpu',
          '--no-zygote',
          '--single-process',
          '--remote-debugging-port=9222'
        ]
      }
    },

    // CI-reporters (Junit voor artifacts)
    reporters: ['progress', 'kjhtml', 'junit'],
    junitReporter: {
      outputDir: 'test-results',
      outputFile: 'junit.xml',
      useBrowserName: false
    },

    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,

    // CI-friendly
    autoWatch: false,
    singleRun: true,
    restartOnFileChange: false
  });
};
