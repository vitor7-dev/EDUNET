/* =====================================================================
   EDUNET - utilitarios compartilhados do front web (PIM IV)
   - Auth: guarda token JWT e dados do usuario
   - api(): chamada HTTP com token, tratamento de erros em portugues
   - el(): monta elementos com textContent (evita XSS: nunca usa innerHTML com dados da API)
   ===================================================================== */

// Endereco da API. Se a API rodar em outra maquina/porta, troque aqui.
const API_URL = "http://localhost:5069";

const Auth = {
    get token() { try { return localStorage.getItem("edunet_token"); } catch { return null; } },
    get usuario() { try { return JSON.parse(localStorage.getItem("usuarioLogado")); } catch { return null; } },
    salvar(token, usuario) {
        localStorage.setItem("edunet_token", token);
        localStorage.setItem("usuarioLogado", JSON.stringify(usuario));
    },
    sair() {
        localStorage.removeItem("edunet_token");
        localStorage.removeItem("usuarioLogado");
    },
    logado() { return !!this.token && !!this.usuario; },
    admin() { return this.logado() && this.usuario.perfil === "Admin"; }
};

function mensagemErro(dados, status) {
    if (dados && typeof dados.mensagem === "string") return dados.mensagem;
    if (dados && dados.errors) {
        const primeiro = Object.values(dados.errors)[0];
        if (Array.isArray(primeiro) && primeiro.length) return primeiro[0];
    }
    if (status === 401) return "Faça login para continuar.";
    if (status === 403) return "Você não tem permissão para esta ação.";
    return "Erro " + status + " ao processar a requisição.";
}

async function api(caminho, { method = "GET", body = null, auth = true } = {}) {
    const headers = { "Content-Type": "application/json" };
    if (auth && Auth.token) headers["Authorization"] = "Bearer " + Auth.token;

    let resposta;
    try {
        resposta = await fetch(API_URL + caminho, {
            method,
            headers,
            body: body ? JSON.stringify(body) : undefined
        });
    } catch {
        throw new Error("Não foi possível conectar à API. Verifique se ela está rodando.");
    }

    let dados = null;
    const texto = await resposta.text();
    if (texto) { try { dados = JSON.parse(texto); } catch { /* resposta sem JSON */ } }

    if (!resposta.ok) {
        if (resposta.status === 401 && auth && Auth.token) {
            Auth.sair();
            throw new Error("Sua sessão expirou. Faça login novamente.");
        }
        throw new Error(mensagemErro(dados, resposta.status));
    }
    return dados;
}

/* ---------- DOM seguro ---------- */
function el(tag, attrs = {}, ...filhos) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs || {})) {
        if (k === "class") e.className = v;
        else if (k.startsWith("on") && typeof v === "function") e.addEventListener(k.slice(2), v);
        else if (v !== null && v !== undefined && v !== false) e.setAttribute(k, v);
    }
    for (const f of filhos.flat()) {
        if (f === null || f === undefined || f === false) continue;
        e.append(f.nodeType ? f : document.createTextNode(String(f)));
    }
    return e;
}

/* ---------- Formatacao ---------- */
function velocidadeTexto(mbps) { return mbps >= 1000 ? (mbps / 1000) + " Gbps" : mbps + " Mbps"; }
function precoTexto(v) { return "R$ " + Number(v).toFixed(2).replace(".", ","); }
function dataTexto(iso) {
    if (!iso) return "";
    const s = String(iso);
    const d = new Date(/(Z|[+-]\d\d:\d\d)$/.test(s) ? s : s + "Z"); // a API grava em UTC
    return d.toLocaleDateString("pt-BR");
}

/* ---------- Mensagens e navegacao ---------- */
function mostrarAviso(elemento, texto, tipo) {
    if (!elemento) return;
    elemento.textContent = texto;
    elemento.classList.remove("hidden", "error", "success");
    elemento.classList.add(tipo);
}

function exigirLogin(paginaDeVolta) {
    if (Auth.logado()) return true;
    try { sessionStorage.setItem("voltarPara", paginaDeVolta); } catch { /* ignora */ }
    window.location.href = "login.html";
    return false;
}

function badgeStatus(status) {
    const classe = { Ativa: "ok", Resolvido: "ok", Pendente: "warn", EmAndamento: "warn", Aberto: "warn", Cancelada: "off" }[status] || "";
    return el("span", { class: "badge " + classe }, status === "EmAndamento" ? "Em andamento" : status);
}

/* ---------- Acessibilidade: VLibras (Libras) em todas as paginas ---------- */
function iniciarVLibras() {
    if (document.querySelector("[vw]")) return;
    const wrapper = el("div", { "vw": "", class: "enabled" },
        el("div", { "vw-access-button": "", class: "active" }),
        el("div", { "vw-plugin-wrapper": "" }, el("div", { class: "vw-plugin-top-wrapper" })));
    document.body.append(wrapper);
    const s = document.createElement("script");
    s.src = "https://vlibras.gov.br/app/vlibras-plugin.js";
    s.onload = () => { try { new window.VLibras.Widget("https://vlibras.gov.br/app"); } catch { /* sem internet */ } };
    document.body.append(s);
}
document.addEventListener("DOMContentLoaded", iniciarVLibras);
