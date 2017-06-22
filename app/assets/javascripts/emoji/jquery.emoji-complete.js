$(document).ready(function () {
    $('.character-count').textcomplete([
        { // emoji strategy
            id: 'emoji',
            match: /\B:([\-+\w]*)$/,
            search: function (term, callback) {
                callback($.map(emojies, function (emoji) {
                    return emoji.indexOf(term) === 0 ? emoji : null;
                }));
            },
            template: function (value) {
                return '<img src="textcomplete/' + value + '.png">' + value;
            },
            replace: function (value) {
                return ':' + value + ': ';
            },
            index: 1
        },
        { // tech companies
            id: 'tech-companies',
            words: ['apple', 'google', 'facebook', 'github'],
            match: /\b(\w{2,})$/,
            search: function (term, callback) {
                callback($.map(this.words, function (word) {
                    return word.indexOf(term) === 0 ? word : null;
                }));
            },
            index: 1,
            replace: function (word) {
                return word + ' ';
            }
        }
    ], {
        onKeydown: function (e, commands) {
            if (e.ctrlKey && e.keyCode === 74) { // CTRL-J
                return commands.KEY_ENTER;
            }
        }
    });
});