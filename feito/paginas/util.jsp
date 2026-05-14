<%-- 
    Funcoes utilitarias para toda a aplicacao 
    Sanitizacao de inputs para prevencao de XSS e validacao de dados
    Acedido por todos os modulos que processam inputs de utilizador
--%>
<%!
    /**
     * Remove tags HTML, aspas, plicas, faz trim e valida null.
     * Devolve uma string vazia se input for null.
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
