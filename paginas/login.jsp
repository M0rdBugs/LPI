<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../basedados/basedados.h" %>

<%
// ISTO É UMA MANEIRA DE FAZER O LOGIN, NÃO SEI SE FUNCIONA
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nome = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Connection conn = (Connection) application.getAttribute("conn");
            if (conn != null) {
                //falta aqui check por password encriptada
                String sql = "SELECT * FROM utilizador WHERE nome = ? AND password = ?";
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
                            response.sendRedirect("adminDashboard.jsp");
                            break;
                        case "funcionario":
                            response.sendRedirect("funcionarioDashboard.jsp");
                            break;
                        case "cliente":
                            response.sendRedirect("clienteDashboard.jsp");
                            break;
                        default:
                            response.sendRedirect("index.html");
                            sessao.invalidate();
                            break;
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



<%
// ISTO É OUTRA MANEIRA DE FAZER O LOGIN, NÃO SEI SE FUNCIONA
    String user = request.getParameter("nome");
    String pass = request.getParameter("password");
    //falta aqui check por password encriptada
    result = state.executeQuery("SELECT * FROM utilizador where nome='" + user + "' and password='" + pass +"'");
    if (result.next()) {
        session.setAttribute("nome", user);
        session.setAttribute("tipo_util", result.getString("tipo_util"));
        session.setAttribute("email", result.getString("email"));
        session.setAttribute("password", result.getString("password"));
        con.close();
        response.sendRedirect("pagina_inicial.jsp");
    } else {
        out.println("Não foi possível efetuar o login.");
        response.sendRedirect("login.html?error=invalid");
        con.close();
    }
%>

