<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    Ficheiro admin_carteira_clientes.jsp, redireciona para gestao de carteiras pelo admin, perfil admin, tabelas carteiras
--%>
<%@ include file="sessao_admin.jsp" %>
<%
    response.sendRedirect("admin_carteiras.jsp");
%>
