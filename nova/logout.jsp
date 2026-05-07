<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidar a sessão actual
    session.invalidate();
    // Redirecionar para a página de login com mensagem de confirmação
    response.sendRedirect("login.jsp?msg=logout");
%>
