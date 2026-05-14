<%-- 
    Termina a sessao do utilizador e redireciona para a página de login com mensagem de confirmação
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    session.invalidate();
    response.sendRedirect("login.jsp?msg=logout");
%>
