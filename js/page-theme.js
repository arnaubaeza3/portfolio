(function () {
  var root = document.documentElement;
  var saved = localStorage.getItem('theme');
  var pref = saved || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  root.setAttribute('data-theme', pref);

  var btn = document.getElementById('themeToggle');
  if (!btn) return;
  btn.addEventListener('click', function () {
    var cur = root.getAttribute('data-theme');
    var nxt = cur === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', nxt);
    localStorage.setItem('theme', nxt);
  });
})();
