<%--
    Ficheiro: perfil.jsp
    Descricao: Pagina de encaminhamento unificado para o perfil do utilizador.
    Redirecciona com base no perfil da sessao activa:
      cliente    -> cliente_perfil.jsp
      funcionario -> func_perfil.jsp
      admin      -> admin_perfil.jsp
      sem sessao -> login.jsp
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String perfil = (String) session.getAttribute("perfil");
    if (perfil == null) {
        response.sendRedirect("login.jsp");
    } else if ("cliente".equals(perfil)) {
        response.sendRedirect("cliente_perfil.jsp");
    } else if ("funcionario".equals(perfil)) {
        response.sendRedirect("func_perfil.jsp");
    } else if ("admin".equals(perfil)) {
        response.sendRedirect("admin_perfil.jsp");
    } else {
        response.sendRedirect("login.jsp");
    }
%>