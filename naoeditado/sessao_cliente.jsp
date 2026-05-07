<%-- 
    Ficheiro: sessao_cliente.jsp
    Descrição: Fragmento de verificação de sessão para páginas de clientes.
    Deve ser incluído no início de cada página restrita a clientes.
    Redireciona para login se o utilizador não tiver sessão activa com perfil 'cliente'.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String _perfil = (String) session.getAttribute("perfil");
    if (_perfil == null || !_perfil.equals("cliente")) {
        response.sendRedirect("login.html");
        return;
    }
%>
