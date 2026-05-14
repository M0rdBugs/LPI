<%-- 
    Ficheiro: home.jsp
    Descricao: Pagina de encaminhamento. Redirecciona o utilizador
    para o dashboard correspondente ao seu perfil. Sem sessao -> index.jsp.
    Perfil de acesso: qualquer utilizador
    Tabelas usadas: Nenhuma
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String perfil = (String) session.getAttribute("tipo_util");
    if (perfil == null) {
        response.sendRedirect("index.jsp");
    } else if ("cliente".equals(perfil)) {
        response.sendRedirect("cliente_dashboard.jsp");
    } else if ("funcionario".equals(perfil)) {
        response.sendRedirect("funcionario_dashboard.jsp");
    } else if ("administrador".equals(perfil)) {
        response.sendRedirect("admin_dashboard.jsp");
    } else {
        response.sendRedirect("index.jsp");
    }
%>
