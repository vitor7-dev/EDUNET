/* Comportamento da pagina inicial (index.html): menu, cabecalho de login e formulario de contato. */
document.addEventListener("DOMContentLoaded", function () {

    window.irParaPagina = function (pagina) {
        document.body.classList.add("fade-out");
        setTimeout(() => { window.location.href = pagina; }, 350);
    };

    /* ---------- Cabecalho conforme o login ---------- */
    const usuario = Auth.logado() ? Auth.usuario : null;
    const btnLoginHeader = document.getElementById("btnLoginHeader");
    const btnSolicitacoes = document.getElementById("btnSolicitacoes");
    const btnAdmin = document.getElementById("btnAdmin");

    if (usuario && btnLoginHeader) {
        btnLoginHeader.textContent = "Olá, " + (usuario.nome || usuario.email) + " | Sair";
        btnLoginHeader.removeAttribute("href");
        btnLoginHeader.onclick = function (e) {
            e.preventDefault();
            if (confirm("Deseja sair da conta?")) {
                Auth.sair();
                window.location.reload();
            }
        };
    }
    if (usuario && btnSolicitacoes) btnSolicitacoes.classList.remove("hidden");
    if (usuario && usuario.perfil === "Admin" && btnAdmin) btnAdmin.classList.remove("hidden");

    /* ---------- Menu mobile e rolagem ---------- */
    const navMobile = document.querySelector(".nav-mobile");
    const menuIcon = document.querySelector(".menu-icon");
    const closeIcon = document.querySelector(".close-icon");

    window.toggleMenu = function () {
        if (navMobile) navMobile.classList.toggle("hidden");
        if (menuIcon) menuIcon.classList.toggle("hidden");
        if (closeIcon) closeIcon.classList.toggle("hidden");
    };

    window.scrollToSection = function (id) {
        const section = document.getElementById(id);
        if (section) section.scrollIntoView({ behavior: "smooth" });
        if (navMobile && !navMobile.classList.contains("hidden")) toggleMenu();
    };

    /* ---------- Planos do formulario vindos da API ---------- */
    const selectPlano = document.getElementById("plan");

    async function carregarPlanosNoSelect() {
        if (!selectPlano) return;
        try {
            const planos = await api("/api/planos", { auth: false });
            selectPlano.replaceChildren(...planos.map(p =>
                el("option", { value: p.idPlano }, p.nomePlano + " - " + velocidadeTexto(p.velocidadeMbps))));
        } catch (erro) {
            selectPlano.replaceChildren(el("option", { value: "" }, "Planos indisponíveis (API desligada)"));
        }
    }
    carregarPlanosNoSelect();

    /* ---------- Formulario de contato ---------- */
    const inputTelefone = document.getElementById("phone");

    if (inputTelefone) {
        inputTelefone.addEventListener("input", function () {
            let valor = inputTelefone.value.replace(/\D/g, "");
            if (valor.length > 11) valor = valor.slice(0, 11);

            if (valor.length <= 10) {
                valor = valor.replace(/^(\d{2})(\d{4})(\d{0,4})/, "($1) $2-$3");
            } else {
                valor = valor.replace(/^(\d{2})(\d{5})(\d{0,4})/, "($1) $2-$3");
            }
            inputTelefone.value = valor;
        });
    }

    function validarEmail(email) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email); }
    function validarTelefone(telefone) {
        const n = telefone.replace(/\D/g, "");
        return n.length === 10 || n.length === 11;
    }
    function validarNome(nome) { return /^[A-Za-zÀ-ÿ\s]{3,100}$/.test(nome); }

    const form = document.getElementById("contactForm");
    const successMessage = document.getElementById("successMessage");
    const formMessage = document.getElementById("formMessage");

    function mostrarMensagem(texto, tipo) {
        mostrarAviso(formMessage, texto, tipo);
        setTimeout(() => formMessage && formMessage.classList.add("hidden"), 4000);
    }

    if (form) {
        form.addEventListener("submit", async function (e) {
            e.preventDefault();

            const nome = document.getElementById("name").value.trim();
            const email = document.getElementById("email").value.trim();
            const telefone = document.getElementById("phone").value.trim();
            const plano = document.getElementById("plan").value;
            const mensagem = document.getElementById("message").value.trim();

            if (!validarNome(nome)) return mostrarMensagem("Digite um nome válido com pelo menos 3 letras.", "error");
            if (!validarEmail(email)) return mostrarMensagem("Digite um e-mail válido.", "error");
            if (!validarTelefone(telefone)) return mostrarMensagem("Digite um telefone válido com DDD.", "error");
            if (!plano) return mostrarMensagem("Selecione um plano de interesse.", "error");
            if (mensagem.length > 300) return mostrarMensagem("A mensagem deve ter no máximo 300 caracteres.", "error");

            try {
                await api("/api/contatos", {
                    method: "POST",
                    auth: false,
                    body: { nome, email, telefone, idPlano: Number(plano), mensagem: mensagem || null }
                });

                mostrarMensagem("Mensagem enviada com sucesso!", "success");
                setTimeout(() => {
                    form.reset();
                    form.classList.add("hidden");
                    if (successMessage) successMessage.classList.remove("hidden");
                }, 800);
            } catch (erro) {
                mostrarMensagem(erro.message, "error");
            }
        });
    }
});
