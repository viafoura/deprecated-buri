<%@ page language="java" import="java.util.*,java.net.*,java.io.*" %>
<%
StringBuffer buffer = new StringBuffer();
for (URL url :
    ((URLClassLoader) (Thread.currentThread()
        .getContextClassLoader())).getURLs()) {
  buffer.append(new File(url.getPath()));
  buffer.append("<br>\n");
}
String classpath = buffer.toString();
%>

<h2>sessionScope.locale= ${sessionScope.locale}</h2>
<h2>sessionScope.localeVariant= ${sessionScope.localeVariant}</h2>
<h5>Classpath = <%= classpath %></h5>

