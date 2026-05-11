#!/usr/bin/env bash
#
# update-portfolio-v2.sh — TODOS los cambios al index.html (idempotente).
# Si un cambio ya está aplicado, lo salta. Seguro de ejecutar varias veces.
#
# Uso: bash update-portfolio-v2.sh   (desde /var/www/html, sin sudo)
#

set -euo pipefail

FILE="index.html"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="${FILE}.bak-${TS}"

if [[ ! -f "$FILE" ]]; then
  echo "❌ No encuentro $FILE. ¿Estás en /var/www/html?"
  exit 1
fi

cp "$FILE" "$BACKUP"
echo "✅ Backup creado: $BACKUP"
echo ""

python3 << 'PYEOF'
import re
import sys

with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

original = html
changes = []
skipped = []

# ═════════════════════════════════════════════════════════════════
#   CAMBIOS V1  (idempotentes)
# ═════════════════════════════════════════════════════════════════

simple_v1 = [
    ('Linux &amp; Cloud <strong>·</strong> Bajo nivel',
     'Backend &amp; Sistemas <strong>·</strong> IA aplicada <strong>·</strong> Bajo nivel',
     'V1·Tagline hero'),
    ('<span class="num">3<em>+</em></span>',
     '<span class="num">5<em>+</em></span>',
     'V1·Stat 3+ → 5+'),
    ('<span class="lbl">Años en código</span>',
     '<span class="lbl">Proyectos públicos</span>',
     'V1·Stat label'),
    ('C · Bash · Python', 'Python · AI · Backend', 'V1·Hero card'),
    ('English (C1)', 'English (B2)', 'V1·Inglés B2'),
    ('<span class="skill-tag">HTML / CSS</span>',
     '<span class="skill-tag">HTML / CSS</span><span class="skill-tag">SQL</span><span class="skill-tag">Java</span>',
     'V1·Lenguajes +SQL/Java'),
    ('<span class="skill-tag">systemd</span>',
     '<span class="skill-tag">systemd</span><span class="skill-tag">fail2ban</span>',
     'V1·Cloud +fail2ban'),
    ('<span class="skill-tag">Agile</span>',
     '<span class="skill-tag">Agile</span><span class="skill-tag">pytest</span><span class="skill-tag">Docker</span>',
     'V1·Tools +pytest/Docker'),
]

for old, new, desc in simple_v1:
    if old in html:
        html = html.replace(old, new)
        changes.append(f"✓ {desc}")
    else:
        skipped.append(f"⊝ {desc}")

# Disponibilidad en contacto (regex multilínea)
pattern_contact = re.compile(
    r'<strong>Suelo responder en menos de 24 h</strong>\s*<span class="sep">·</span>\s*Barcelona, UTC\+1',
    re.DOTALL)
contact_new = (
    '<strong>Disponible tardes (L-V 15:00+) y fines de semana completos.</strong>\n'
    '      <span class="sep">·</span>\n'
    '      Abierto a prácticas, convenio universitario y contratos parciales.\n'
    '      <span class="sep">·</span>\n'
    '      <strong>Respondo en menos de 24 h</strong>\n'
    '      <span class="sep">·</span>\n'
    '      Barcelona, UTC+1')
new_html, n = pattern_contact.subn(contact_new, html, count=1)
if n:
    html = new_html
    changes.append("✓ V1·Contacto disponibilidad")
else:
    skipped.append("⊝ V1·Contacto disponibilidad")

# Renumerar proyectos
if '<span class="proj-num">05</span>' not in html:
    for old_num, new_num in [('04', '05'), ('03', '04'), ('02', '03'), ('01', '02')]:
        old_tag = f'<span class="proj-num">{old_num}</span>'
        new_tag = f'<span class="proj-num">{new_num}</span>'
        if old_tag in html:
            html = html.replace(old_tag, new_tag, 1)
            changes.append(f"✓ V1·Renumerar {old_num}→{new_num}")
else:
    skipped.append("⊝ V1·Renumerar proyectos")

# 3 bloques nuevos al stack
new_skill_blocks = '''
        <div class="skill-block reveal reveal-delay-1">
          <div class="skill-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg></div>
          <h4>Backend &amp; APIs</h4>
          <div class="skill-tags">
            <span class="skill-tag">Flask</span><span class="skill-tag">Flask-SocketIO</span>
            <span class="skill-tag">REST APIs</span><span class="skill-tag">WebSockets</span>
            <span class="skill-tag">PWA</span><span class="skill-tag">SQLite</span>
          </div>
        </div>

        <div class="skill-block reveal reveal-delay-2">
          <div class="skill-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v6M12 17v6M4.22 4.22l4.24 4.24M15.54 15.54l4.24 4.24M1 12h6M17 12h6M4.22 19.78l4.24-4.24M15.54 8.46l4.24-4.24"/></svg></div>
          <h4>IA &amp; Computer Vision</h4>
          <div class="skill-tags">
            <span class="skill-tag">OpenAI API</span><span class="skill-tag">GPT-4o-mini</span>
            <span class="skill-tag">Whisper</span><span class="skill-tag">OpenCV</span>
            <span class="skill-tag">Resemblyzer</span><span class="skill-tag">RAG / TF-IDF</span>
          </div>
        </div>

        <div class="skill-block reveal reveal-delay-3">
          <div class="skill-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></div>
          <h4>Frontend &amp; 3D</h4>
          <div class="skill-tags">
            <span class="skill-tag">Three.js</span><span class="skill-tag">GLSL</span>
            <span class="skill-tag">Chart.js</span><span class="skill-tag">ES6+</span>
          </div>
        </div>
'''

if 'Backend &amp; APIs' not in html:
    pattern_idiomas = re.compile(
        r'(<h4>Idiomas</h4>\s*<div class="skill-tags">.*?</div>\s*</div>)',
        re.DOTALL)
    match = pattern_idiomas.search(html)
    if match:
        html = html[:match.end()] + new_skill_blocks + html[match.end():]
        changes.append("✓ V1·Stack +3 bloques")
    else:
        skipped.append("⊝ V1·Stack +3 bloques (no encontrado)")
else:
    skipped.append("⊝ V1·Stack +3 bloques")

# CampusBot como proyecto 01
campusbot_html = '''      <a href="https://github.com/arnaubaeza3" target="_blank" rel="noopener" class="project-row reveal">
        <span class="proj-num">01</span>
        <div class="proj-info">
          <p class="proj-name">CampusBot &mdash; Asistente de voz con IA</p>
          <p class="proj-desc">Robot guía para la Escola d'Enginyeria UAB con reconocimiento facial (OpenCV + SFace), identificación de voz (Resemblyzer), GPT-4o-mini, RAG TF-IDF propio y frontend 3D en Three.js. Arquitectura multi-instancia con Socket.IO + PWA instalable.</p>
        </div>
        <div class="proj-tags">
          <span class="proj-tag">Python</span><span class="proj-tag">Flask</span>
          <span class="proj-tag">OpenAI</span><span class="proj-tag">OpenCV</span>
          <span class="proj-tag">Three.js</span>
        </div>
        <span class="proj-arrow" aria-hidden="true">
          <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 10h12M10 4l6 6-6 6"/></svg>
        </span>
      </a>

'''

if 'CampusBot' not in html:
    pattern_first_project = re.compile(
        r'(<div class="projects-list">\s*)(<a[^>]*class="project-row)',
        re.DOTALL)
    match = pattern_first_project.search(html)
    if match:
        insert_pos = match.end(1)
        html = html[:insert_pos] + campusbot_html + html[insert_pos:]
        changes.append("✓ V1·CampusBot proyecto 01")
    else:
        skipped.append("⊝ V1·CampusBot")
else:
    skipped.append("⊝ V1·CampusBot")


# ═════════════════════════════════════════════════════════════════
#   CAMBIOS V2  (nuevos)
# ═════════════════════════════════════════════════════════════════

# V2-1: Reescribir párrafo about-text
old_about = re.compile(
    r'<p class="about-text reveal reveal-delay-2">\s*'
    r'No solo escribo código:\s*resuelvo problemas\..*?'
    r'</p>',
    re.DOTALL)
new_about = '''<p class="about-text reveal reveal-delay-2">
        No solo escribo código: construyo sistemas completos. Desde una VM Linux
        autogestionada en Azure hasta <strong>CampusBot</strong> — un asistente de voz
        con IA, reconocimiento facial y frontend 3D — me interesa entender cada capa
        del stack, del kernel a la UX. Esta misma web está servida desde una VM
        Ubuntu en Azure que administro yo, desde el bootloader hasta el certificado TLS.
      </p>'''

new_html, n = old_about.subn(new_about, html, count=1)
if n:
    html = new_html
    changes.append("✓ V2·About reescrito")
else:
    if 'del kernel a la UX' in html:
        skipped.append("⊝ V2·About reescrito (ya está)")
    else:
        skipped.append("⊝ V2·About (no encontrado)")

# V2-2: Timeline 2025 (CampusBot)
timeline_2025 = '''
              <div class="timeline-item">
                <span class="timeline-year">2025<em>·</em></span>
                <div class="timeline-content">
                  <h4>CampusBot — Asistente de voz con IA</h4>
                  <p>Robot guía para la Escola d'Enginyeria UAB: OpenAI GPT-4o-mini, reconocimiento facial con OpenCV y frontend 3D en Three.js.</p>
                </div>
              </div>
'''

if '<span class="timeline-year">2025' not in html:
    pattern_2026 = re.compile(
        r'(<div class="timeline-item">\s*<span class="timeline-year">2026.*?</div>\s*</div>)',
        re.DOTALL)
    match = pattern_2026.search(html)
    if match:
        html = html[:match.end()] + timeline_2025 + html[match.end():]
        changes.append("✓ V2·Timeline 2025 (CampusBot)")
    else:
        skipped.append("⊝ V2·Timeline 2025 (no encontrado 2026)")
else:
    skipped.append("⊝ V2·Timeline 2025")

# V2-3: Botón Descargar CV
btn_cv = '''        <a href="/cv-arnau-baeza.pdf" download class="btn btn-secondary">
          Descargar CV
          <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10 3v10M5 9l5 5 5-5M4 17h12"/></svg>
        </a>
'''

if 'cv-arnau-baeza.pdf' not in html:
    pattern_btn = re.compile(
        r'(<a href="#contact" class="btn btn-secondary">Contactar</a>\s*)',
        re.DOTALL)
    new_html, n = pattern_btn.subn(r'\1' + btn_cv, html, count=1)
    if n:
        html = new_html
        changes.append("✓ V2·Botón Descargar CV")
    else:
        skipped.append("⊝ V2·Botón CV (no encontrado)")
else:
    skipped.append("⊝ V2·Botón CV")

# V2-4: Open Graph + Twitter Card meta tags
og_meta = '''
  <!-- Open Graph -->
  <meta property="og:type" content="website"/>
  <meta property="og:url" content="https://arnauserver.me"/>
  <meta property="og:title" content="Arnau Baeza — Backend, Cloud &amp; IA aplicada"/>
  <meta property="og:description" content="Estudiante de Ingeniería Informática (UAB). Backend, sistemas Linux self-hosted e IA aplicada. Disponible para prácticas."/>
  <meta property="og:image" content="https://arnauserver.me/images/og-preview.png"/>
  <meta property="og:image:width" content="1200"/>
  <meta property="og:image:height" content="630"/>
  <meta property="og:locale" content="es_ES"/>

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image"/>
  <meta name="twitter:title" content="Arnau Baeza — Backend, Cloud &amp; IA aplicada"/>
  <meta name="twitter:description" content="Estudiante de Ingeniería Informática (UAB). Disponible para prácticas."/>
  <meta name="twitter:image" content="https://arnauserver.me/images/og-preview.png"/>

  <meta name="description" content="Portfolio personal de Arnau Baeza Muñoz — estudiante de Ingeniería Informática (UAB), desarrollador backend y de sistemas Linux. Self-hosted en Azure."/>
  <meta name="author" content="Arnau Baeza Muñoz"/>
'''

if 'og:title' not in html:
    new_html, n = re.subn(
        r'(<title>[^<]*</title>)',
        r'\1' + og_meta,
        html, count=1)
    if n:
        html = new_html
        changes.append("✓ V2·Open Graph meta tags")
    else:
        skipped.append("⊝ V2·OG meta (no encontrado <title>)")
else:
    skipped.append("⊝ V2·OG meta")

# V2-5: Live status check (JS sutil que verifica /monitor)
live_check_script = '''
  <script>
    // Live status check: verifica que /monitor responde y refuerza el badge Disponible
    (function () {
      const eyebrow = document.querySelector('.hero-eyebrow');
      if (!eyebrow) return;
      fetch('/monitor/', { method: 'HEAD', cache: 'no-store' })
        .then(function (r) {
          if (r.ok || r.status < 500) {
            const dot = eyebrow.querySelector('.live-dot');
            if (dot) dot.title = 'Servidor activo · /monitor responde';
            // Marcar visualmente como verificado (sin romper layout)
            eyebrow.setAttribute('data-server-active', 'true');
          }
        })
        .catch(function () { /* silencioso */ });
    })();
  </script>
'''

if 'Live status check' not in html:
    new_html, n = re.subn(
        r'(</body>)',
        live_check_script + r'\1',
        html, count=1)
    if n:
        html = new_html
        changes.append("✓ V2·Live status check JS")
    else:
        skipped.append("⊝ V2·Live status (no encontrado </body>)")
else:
    skipped.append("⊝ V2·Live status")


# ═════════════════════════════════════════════════════════════════
#   GUARDAR
# ═════════════════════════════════════════════════════════════════

if html == original:
    print("⚠ Nada cambió. Todos los cambios ya están aplicados.")
    for s in skipped:
        print(f"  {s}")
    sys.exit(0)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

if changes:
    print("APLICADOS:")
    for c in changes:
        print(f"  {c}")

if skipped:
    print("\nSALTADOS (ya estaba o no encontrado):")
    for s in skipped:
        print(f"  {s}")

print(f"\n✅ index.html: {len(original)} → {len(html)} chars ({len(html) - len(original):+d})")
PYEOF

echo ""
echo "════════════════════════════════════════════════════"
echo "  PASOS PENDIENTES (manuales)"
echo "════════════════════════════════════════════════════"
echo ""
echo "Para que el OG preview y el botón 'Descargar CV' funcionen,"
echo "necesitas subir DOS archivos a la VM:"
echo ""
echo "  1. og-preview.png  →  /var/www/html/images/og-preview.png"
echo "  2. Curriculum_Arnau_Baeza.pdf  →  /var/www/html/cv-arnau-baeza.pdf"
echo ""
echo "Desde tu Mac:"
echo "  scp og-preview.png azureuser@<IP>:/var/www/html/images/"
echo "  scp Curriculum_Arnau_Baeza.pdf azureuser@<IP>:/var/www/html/cv-arnau-baeza.pdf"
echo ""
echo "Si nginx sirve solo lo que tiene www-data permisos:"
echo "  chmod 644 /var/www/html/images/og-preview.png"
echo "  chmod 644 /var/www/html/cv-arnau-baeza.pdf"
echo ""
echo "Verificar que la web responde:"
echo "  curl -s -o /dev/null -w '%{http_code}\\n' https://arnauserver.me"
echo "  curl -s -o /dev/null -w '%{http_code}\\n' https://arnauserver.me/cv-arnau-baeza.pdf"
echo "  curl -s -o /dev/null -w '%{http_code}\\n' https://arnauserver.me/images/og-preview.png"
echo ""
echo "Commit y push:"
echo "  git add index.html"
echo "  git commit -m 'Portfolio v2: about reescrito, timeline 2025, CV download, OG meta'"
echo "  git push"
echo ""
echo "Probar el OG preview en https://www.opengraph.xyz o LinkedIn Post Inspector"
echo ""
echo "Si algo falla, revertir:"
echo "  cp $BACKUP $FILE"
echo ""
