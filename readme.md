# Portfolio — arnauserver.me

Portfolio personal desplegado en producción en Microsoft Azure.

🌐 **Live:** [arnauserver.me](https://arnauserver.me)

---

## 🛠️ Stack

![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![Azure](https://img.shields.io/badge/Azure-0089D6?style=for-the-badge&logo=microsoftazure&logoColor=white)
![nginx](https://img.shields.io/badge/nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)

---

## 📁 Estructura

```
portfolio/
└── index.html   # Web completa en un solo archivo
```

---

## ✨ Características

- Diseño responsive (móvil, tablet y escritorio)
- Animaciones CSS con `@keyframes` y `IntersectionObserver`
- Layout con CSS Grid y Flexbox
- Variables CSS para sistema de diseño consistente
- Efecto glassmorphism en la barra de navegación
- Sin frameworks ni dependencias externas — HTML y CSS vanilla

---

## 🚀 Despliegue

La web está servida desde una VM Ubuntu en Azure con nginx y HTTPS activado via Let's Encrypt.

Más detalles sobre la infraestructura: [azure-linux-server](https://github.com/arnaubaeza3/azure-linux-server)
