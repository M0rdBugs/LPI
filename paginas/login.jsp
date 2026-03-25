<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../basedados/basedados.h" %>



<%
 Connection conn = null;

 Class.forName("com.mysql.jdbc.Driver").newInstance();
 String jdbcURL="jdbc:mysql://localhost:3306/trabalho1"; // BD "jsp"
 conn = DriverManager.getConnection(jdbcURL,"root", "root");

 PreparedStatement psSelectRecord= null;
 ResultSet rsSelectRecord= null;
 String sqlSelectRecord= null;

 sqlSelectRecord ="SELECT * FROM contacto"; // tabela "contacto"
 psSelectRecord=conn.prepareStatement(sqlSelectRecord);
 //psSelectRecord.setString(1,"Marketing");
 rsSelectRecord=psSelectRecord.executeQuery();

%>
<%
<<<<<<< Updated upstream
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nome = request.getParameter("nome");
        String password = request.getParameter("password_hash");
=======
        //  Não sei como inverter o Hash..
        String nome1 = request.getParameter("nome");
        String password = request.getParameter("password");
>>>>>>> Stashed changes

        try 
        {
            Connection conn = (Connection) application.getAttribute("conn");
            if (conn != null) {

                String sql = "SELECT * FROM utilizador WHERE nome = ? AND password_hash = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nome1);
                pstmt.setString(2, password);
                ResultSet resultado = pstmt.executeQuery();

                if (resultado.next()) {
                    String tipoUtilizador = resultado.getString("tipo_util");
                    HttpSession sessao = request.getSession();
                    sessao.setAttribute("utilizador_id", resultado.getInt("utilizador_id"));
                    sessao.setAttribute("tipo_util", tipoUtilizador);
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
                            sessao.invalidate();    
                            response.sendRedirect("index.html");
                            return;
                    }
                } else {
                    response.sendRedirect("login.html");
                    resultado.close();
                    pstmt.close();
                    return;
                }
            } else {
                    out.println("<p>Conexão com a base de dados não está estabelecida.</p>");
                    return;
                }

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Erro: " + e.getMessage() + "</p>");
            response.sendRedirect("login.html");

        }
%>


