<%-- 
    Ficheiro: sessao_funcionario.jsp
    Descrição: Fragmento de verificação de sessão para páginas de funcionários.
    Permite acesso a funcionários e administradores.
    Redireciona para login se o utilizador não tiver o perfil adequado.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String _perfil = (String) session.getAttribute("perfil");
    if (_perfil == null || (!_perfil.equals("funcionario") && !_perfil.equals("admin"))) {
        response.sendRedirect("login.html");
        return;
    }
%>
