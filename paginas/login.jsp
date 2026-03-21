<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../basedados/basedados.h.jsp" %>

<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nome = request.getParameter("username");
        String password = request.getParameter("password_hash");

        try {
            Connection conn = (Connection) application.getAttribute("conn");
            if (conn != null) {
                //falta aqui check por password encriptada
                String sql = "SELECT * FROM utilizador WHERE nome = ? AND password_hash = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nome);
                pstmt.setString(2, password);
                ResultSet resultado = pstmt.executeQuery();

                if (resultado.next()) {
                    String tipoUtilizador = resultado.getString("tipo_utilizador");
                    HttpSession sessao = request.getSession();
                    sessao.setAttribute("user_id", resultado.getInt("utilizador_id"));
                    sessao.setAttribute("tipo_utilizador", tipoUtilizador);

                    switch (tipoUtilizador) {
                        case "admin":
                            sessao.setAttribute("admin", true);
                            response.sendRedirect("adminDashboard.jsp");
                            return;
                        case "funcionario":
                            sessao.setAttribute("funcionario", true);
                            response.sendRedirect("funcionarioDashboard.jsp");
                            return;
                        case "cliente":
                            sessao.setAttribute("cliente", true);
                            response.sendRedirect("cliente.jsp");
                            return;
                        default:
                            response.sendRedirect("index.html");
                            sessao.invalidate();
                            return;
                    }
                } else {
                    response.sendRedirect("login.jsp?error=invalid");
                }
            } else {
                out.println("<p>Conexão com a base de dados não está estabelecida.</p>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Erro: " + e.getMessage() + "</p>");
        }
    }
%>


