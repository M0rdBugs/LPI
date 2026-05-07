<%-- 
    Ficheiro: util.jsp
    Descricao: Funcoes utilitarias para toda a aplicacao, incluindo sanitizacao
    de inputs para prevencao de XSS e validacao de dados.
    Acedido por: Todos os modulos que processam inputs de utilizador.
    Tabelas da BD usadas: Nenhuma (funcoes auxiliares).
--%>
<%!
    /**
     * Remove tags HTML, faz trim e valida null.
     * Devolve string vazia se input for null.
     */
    public String sanitize(String input) {
        if (input == null) return "";
        String s = input.trim();
        s = s.replaceAll("<[^>]*>", "");
        s = s.replaceAll("[\"'`]", "");
        return s;
    }

    /**
     * Valida se uma string e um numero decimal valido.
     */
    public boolean isDecimal(String s) {
        if (s == null || s.trim().isEmpty()) return false;
        try {
            Double.parseDouble(s.trim());
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Valida se uma string e um numero inteiro valido.
     */
    public boolean isInteger(String s) {
        if (s == null || s.trim().isEmpty()) return false;
        try {
            Integer.parseInt(s.trim());
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
%>
