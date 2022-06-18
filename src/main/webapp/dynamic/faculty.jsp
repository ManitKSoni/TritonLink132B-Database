<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
	<body>
		<table>
			<tr>
				<td>
					<jsp:include page="menu.html" />
				</td>
				<td>
				<%-- Set the scripting language to java and --%>
				<%-- import the java.sql package --%>
				<%@ page language="java" import="java.sql.*" %>
				<%
					try {
					// Load Oracle Driver class file
					DriverManager.registerDriver(new org.postgresql.Driver());
					
					// Make a connection to the Oracle datasource
					Connection conn = DriverManager.getConnection
					("jdbc:postgresql:project?user=postgres&password=Poseidon123@");
				%>
				
				<%
				// Check if an insertion is requested
				String action = request.getParameter("action");
				if (action != null && action.equals("insert")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// INSERT the student attrs INTO the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					("INSERT INTO faculty VALUES (?,?,?)"));
					
					pstmt.setString(1, request.getParameter("NAME"));
					pstmt.setString(2, request.getParameter("TITLE"));
					pstmt.setString(3, request.getParameter("DEPT_NAME"));
					
					pstmt.executeUpdate();
					
					conn.commit();
					conn.setAutoCommit(true);
				}
				
				// Check if an update is requested
				if (action != null && action.equals("update")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// UPDATE the student attributes in the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					"UPDATE faculty SET TITLE = ?, DEPT_NAME = ? WHERE NAME = ?");
					
					pstmt.setString(1, request.getParameter("TITLE"));
					pstmt.setString(2, request.getParameter("DEPT_NAME"));
					pstmt.setString(3, request.getParameter("NAME"));
					int rowCount = pstmt.executeUpdate();
					
					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				
				// Check if a delete is requested
				if (action != null && action.equals("delete")) {
					conn.setAutoCommit(false);
					
					// Create the prepared statement and use it to
					// DELETE the student FROM the Student table.
					PreparedStatement pstmt = conn.prepareStatement(
					"DELETE FROM faculty WHERE NAME = ?");
					
					pstmt.setString(1, request.getParameter("NAME"));
					int rowCount = pstmt.executeUpdate();
					
					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				%>
				
				<%
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the Class table.
				ResultSet rs = statement.executeQuery("SELECT * FROM faculty");
				%>
				
				<table>
					<tr>
						<th>Name</th>
						<th>Title</th>
						<th>Department</th>
					</tr>
					
					<tr>
						<form action="faculty.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="NAME" size="10"></th>
							<th><input value="" name="TITLE" size="10"></th>
							<th><input value="" name="DEPT_NAME" size="15"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet
					while ( rs.next() ) {
				%>
					<tr>
						<form action="faculty.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs.getString("NAME") %>" name="NAME"></td>
							<td><input value="<%= rs.getString("TITLE") %>" name="TITLE"></td>
							<td><input value="<%= rs.getString("DEPT_NAME") %>" name="DEPT_NAME"></td>
							… <td><input type="submit" value="Update"></td>
						</form>
						<form action="faculty.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs.getString("NAME") %>" name="NAME">
							<td><input type="submit" value="Delete"></td>
						</form>
					</tr>
				<%
					}
				%>
				</table>
				
				<%
				// Close the ResultSet
				rs.close();
				// Close the Statement
				statement.close();
				// Close the Connection
				conn.close();
				} catch (SQLException sqle) {
				out.println(sqle.getMessage());
				} catch (Exception e) {
				out.println(e.getMessage());
				}
				%>
				</td>
			</tr>
		</table>
	</body>
</html>