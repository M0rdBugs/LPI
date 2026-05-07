<%-- 
    Ficheiro: sessao_admin.jsp
    Descrição: Fragmento de verificação de sessão para páginas exclusivas de administradores.
    Redireciona para login se o utilizador não tiver perfil 'admin'.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String _perfil = (String) session.getAttribute("perfil");
    if (_perfil == null || !_perfil.equals("admin")) {
        response.sendRedirect("login.html");
        return;
    }
%>
