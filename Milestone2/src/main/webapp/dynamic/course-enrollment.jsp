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
					// INSERT the review_meeting attrs INTO the academic_history table.

					PreparedStatement pstmt = conn.prepareStatement(("SELECT enroll_list_id, waitlist_id, enroll_limit FROM class WHERE year = 2018 and UPPER(qtr) = 'SPRING' and course_id = ? and section_id = ?"));
					pstmt.setString(1, request.getParameter("COURSE_ID"));
					pstmt.setString(2, request.getParameter("SECTION_ID"));
					ResultSet rs = pstmt.executeQuery();
					if(rs.next()){

						int enroll_list_id = rs.getInt(1);
						int waitlist_id = rs.getInt(2);
						int enroll_limit = rs.getInt(3);

						pstmt = conn.prepareStatement(("SELECT COUNT(*) FROM enroll_list WHERE enroll_list_id = ?"));
						pstmt.setInt(1, enroll_list_id);
						ResultSet rs2 = pstmt.executeQuery();
						rs2.next();

						pstmt = conn.prepareStatement(("INSERT INTO enroll_list VALUES (?,?,?,?)"));
						pstmt.setInt(1, enroll_list_id);
						pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
						pstmt.setString(3, request.getParameter("GRADE"));
						pstmt.setInt(4, Integer.parseInt(request.getParameter("UNITS")));
						pstmt.executeUpdate(); 

						if(rs2.getInt(1) < enroll_limit ){

							// insert into academic_history if actually enrolled
							// PreparedStatement pstmt2 = conn.prepareStatement(
							// ("INSERT INTO academic_history VALUES (?,?,?,?,?,?,?)"));
							// 
							// pstmt2.setString(1, request.getParameter("SECTION_ID"));
							// pstmt2.setInt(2, 2018);
							// pstmt2.setString(3, "SPRING");
							// pstmt2.setString(4, request.getParameter("COURSE_ID"));
							// pstmt2.setInt(5, Integer.parseInt(request.getParameter("STUDENT_ID")));
							// pstmt2.setString(6, "IN");
							// pstmt2.setInt(7, Integer.parseInt(request.getParameter("UNITS")));
							// pstmt2.executeUpdate();
							// pstmt2.close();
						}
						// otherwise put them on the waitlist
						else{
							// pstmt = conn.prepareStatement(("INSERT INTO wait_list VALUES (?,?,?,?)"));
							// pstmt.setInt(1, waitlist_id);
							// pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
							// pstmt.setString(3, request.getParameter("GRADE"));
							// pstmt.setInt(4, Integer.parseInt(request.getParameter("UNITS")));
							// pstmt.executeUpdate(); 

							%>
							<!-- Give user a message that student is on waitlist -->
							<%

						}
						rs2.close();
					}
					rs.close();
					
					conn.commit();
					conn.setAutoCommit(true);
				}
				
				// Check if an update is requested
				if (action != null && action.equals("update")) {
					
					// Create the prepared statement and use it to
					// UPDATE the review_meeting attributes in the review_meeting table.
					PreparedStatement pstmt = conn.prepareStatement(("SELECT enroll_list_id, waitlist_id, enroll_limit FROM class WHERE year = 2018 and UPPER(qtr) = 'SPRING' and course_id = ? and section_id = ?"));
					pstmt.setString(1, request.getParameter("COURSE_ID"));
					pstmt.setString(2, request.getParameter("SECTION_ID"));
					ResultSet rs = pstmt.executeQuery();
					rs.next();

					int enroll_list_id = rs.getInt(1);
					int waitlist_id = rs.getInt(2);
					int enroll_limit = rs.getInt(3);

					pstmt = conn.prepareStatement(("SELECT COUNT(*) FROM enroll_list WHERE ENROLL_LIST_ID = ? and STUDENT_ID = ? "));
					pstmt.setInt(1, enroll_list_id);
					pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();
					rs.next();

					// is wait listed
					if(rs.getInt(1) == 0){
						pstmt = conn.prepareStatement("UPDATE wait_list SET GRADE = ?, UNITS = ? WHERE WAITLIST_ID = ? and STUDENT_ID = ?");
						pstmt.setString(1, request.getParameter("GRADE"));
						pstmt.setInt(2, Integer.parseInt(request.getParameter("UNITS")));
						pstmt.setInt(3, waitlist_id);
						pstmt.setInt(4, Integer.parseInt(request.getParameter("STUDENT_ID")));
						pstmt.executeUpdate();
					}
					// is enrolled
					else{
						pstmt = conn.prepareStatement("UPDATE enroll_list SET GRADE = ?, UNITS = ? WHERE ENROLL_LIST_ID = ? and STUDENT_ID = ?");
						pstmt.setString(1, request.getParameter("GRADE"));
						pstmt.setInt(2, Integer.parseInt(request.getParameter("UNITS")));
						pstmt.setInt(3, enroll_list_id);
						pstmt.setInt(4, Integer.parseInt(request.getParameter("STUDENT_ID")));
						pstmt.executeUpdate();
					}
					
					rs.close();
					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				
				// Check if a delete is requested
				if (action != null && action.equals("delete")) {
					conn.setAutoCommit(false);
					
					PreparedStatement pstmt = pstmt = conn.prepareStatement(("SELECT enroll_list_id, waitlist_id, enroll_limit FROM class WHERE year = 2018 and UPPER(qtr) = 'SPRING' and course_id = ? and section_id = ?"));
					pstmt.setString(1, request.getParameter("COURSE_ID"));
					pstmt.setString(2, request.getParameter("SECTION_ID"));
					ResultSet rs = pstmt.executeQuery();
					rs.next();

					int enroll_list_id = rs.getInt(1);
					int waitlist_id = rs.getInt(2);
					int enroll_limit = rs.getInt(3);

					pstmt = conn.prepareStatement(("SELECT COUNT(*) FROM enroll_list WHERE ENROLL_LIST_ID = ? and STUDENT_ID = ? "));
					pstmt.setInt(1, enroll_list_id);
					pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();
					rs.next();

					// is wait listed
					if(rs.getInt(1) == 0){
						pstmt = conn.prepareStatement("DELETE FROM wait_list WHERE WAITLIST_ID = ? and STUDENT_ID = ?");
						pstmt.setInt(1, waitlist_id);
						pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
						pstmt.executeUpdate();
					}
					// is enrolled
					else{
						pstmt = conn.prepareStatement("DELETE FROM enroll_list WHERE ENROLL_LIST_ID = ? and STUDENT_ID = ?");
						pstmt.setInt(1, enroll_list_id);
						pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
						pstmt.executeUpdate();

						pstmt = conn.prepareStatement("DELETE FROM academic_history WHERE year = 2018 and UPPER(qtr) = 'SPRING' and COURSE_ID = ? and STUDENT_ID = ?");
						pstmt.setString(1, request.getParameter("COURSE_ID"));
						pstmt.setInt(2, Integer.parseInt(request.getParameter("STUDENT_ID")));
						pstmt.executeUpdate();
					}

					

					conn.setAutoCommit(false);
					conn.setAutoCommit(true);
				}
				%>
				
				<%
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				ResultSet rs = statement.executeQuery("SELECT * FROM class where year = 2018 and UPPER(qtr) = 'SPRING' ");
				%>
				
				<table>
					<tr>
						<th>Student ID</th>
						<th>Course ID</th>
						<th>Section ID</th>
						<th>Number of Units</th>
						<th>Grade Option</th>
					</tr>
					
					<tr>
						<form action="course-enrollment.jsp" method="get">
							<input type="hidden" value="insert" name="action">
							<th><input value="" name="STUDENT_ID"></th>
							<th><input value="" name="COURSE_ID"></th>
							<th><input value="" name="SECTION_ID"></th>
							<th><input type="number" value="" name="UNITS"></th>
							<th><input value="" name="GRADE"></th>
							<th><input type="submit" value="Insert"></th>
						</form>
					</tr>
				<%
					// Iterate over the ResultSet of all classes
					while ( rs.next() ) {
						int enroll_list_id = rs.getInt("ENROLL_LIST_ID");
						int waitlist_id = rs.getInt("WAITLIST_ID");
						PreparedStatement pstmt = conn.prepareStatement(("SELECT * FROM enroll_list WHERE enroll_list_id = ? "));
						pstmt.setInt(1, enroll_list_id);
						ResultSet rs2 = pstmt.executeQuery();

						// iterate over enrolled students in the class
						while( rs2.next()){

				%>
					<tr>
						<form action="course-enrollment.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs2.getInt("STUDENT_ID") %>" name="STUDENT_ID"></td>
							<td><input value="<%= rs.getString("COURSE_ID") %>" name="COURSE_ID"></td>
							<td><input value="<%= rs.getString("SECTION_ID") %>" name="SECTION_ID"></td>
							<td><input value="<%= rs2.getInt("UNITS") %>" name="UNITS"></td>
							<td><input value="<%= rs2.getString("GRADE") %>" name="GRADE"></td>
							<td><input type="submit" value="Update"></td>
						</form>
						<form action="course-enrollment.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs2.getInt("STUDENT_ID") %>" name="STUDENT_ID">
							<input type="hidden" value="<%= rs.getString("COURSE_ID") %>" name="COURSE_ID">
							<input type="hidden" value="<%= rs.getString("SECTION_ID") %>" name="SECTION_ID">
							<td><input type="submit" value="Delete"></td>
						</form>
					</tr>
				<%
						}

						pstmt = conn.prepareStatement(("SELECT * FROM wait_list WHERE waitlist_id = ? "));
						pstmt.setInt(1, waitlist_id);
						rs2 = pstmt.executeQuery();

						// iterate over waitlist students in the class
						while( rs2.next()){
				%>
					<tr>
						<form action="course-enrollment.jsp" method="get">
							<input type="hidden" value="update" name="action">
							<td><input value="<%= rs2.getInt("STUDENT_ID") %>" name="STUDENT_ID"></td>
							<td><input value="<%= rs.getString("COURSE_ID") %>" name="COURSE_ID"></td>
							<td><input value="<%= rs.getString("SECTION_ID") %>" name="SECTION_ID"></td>
							<td><input value="<%= rs2.getInt("UNITS") %>" name="UNITS"></td>
							<td><input value="<%= rs2.getString("GRADE") %>" name="GRADE"></td>
							… <td><input type="submit" value="Update"></td>
						</form>
						<form action="course-enrollment.jsp" method="get">
							<input type="hidden" value="delete" name="action">
							<input type="hidden" value="<%= rs2.getInt("STUDENT_ID") %>" name="STUDENT_ID">
							<input type="hidden" value="<%= rs.getString("COURSE_ID") %>" name="COURSE_ID">
							<input type="hidden" value="<%= rs.getString("SECTION_ID") %>" name="SECTION_ID">
							<td><input type="submit" value="Delete"></td>
						</form>
					</tr>
				<%
						}
						rs2.close();

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
