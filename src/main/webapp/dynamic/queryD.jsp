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
					("jdbc:postgresql:tritonlink?user=postgres");
				%>
				
				<%
				String action = request.getParameter("action");
				// Create the statement
				Statement statement = conn.createStatement();
				// Use the statement to SELECT the class attributes
				// FROM the academic_history table.
				// gets all students ever enrolled
				ResultSet rs = statement.executeQuery("SELECT * from undergraduate");
				%>
				
				<table>
					<tr>
						<form action="queryD.jsp" method="get">
							<input type="hidden" value="get" name="action">
							<label for="student-select">Choose a Undergrad:</label>

							<select name="STUDENT_ID" id="student-select">
							  <option value="">--Please choose an  Undergrad--</option>
							
				<%
					// Iterate over all students ever enrolled
					while ( rs.next() ) {
						PreparedStatement pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
						pstmt.setInt(1, rs.getInt("STUDENT_ID"));
						ResultSet rs2 = pstmt.executeQuery();
						rs2.next();

				%>
								<option value="<%= rs.getInt("STUDENT_ID") %>">ID: <%= rs2.getInt("STUDENT_ID") %>, Name: <%= rs2.getString("FIRST_NAME") %> <%= rs2.getString("MIDDLE_NAME") %> <%= rs2.getString("LAST_NAME") %></option>
				<%

					}
				%>
							</select><br>
							<label for="degree-select">Choose a Degree:</label>
							<select name="DEGREE_NAME" id="degree-select">
							  <option value="">--Please choose an  Degree--</option>
							
				<%
					// Iterate over all possible degrees
					ResultSet rs3 = statement.executeQuery("SELECT * from degree where DEGREE_TYPE = 'B.S'");
					while ( rs3.next() ) {
				%>
								<option value="<%= rs3.getString("DEGREE_NAME") %>">Name: <%= rs3.getString("DEGREE_NAME") %>, Type: <%= rs3.getString("DEGREE_TYPE") %></option>
				<%

					}
				%>
							</select>
							<th><input type="submit" value="Get"></th>
						</form>
					</tr>
				</table>

				<%
				// Check if an get is requested
				if (action != null && action.equals("get")){
					boolean isTaking = true;

					PreparedStatement pstmt = conn.prepareStatement("SELECT * from student where STUDENT_ID = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					rs = pstmt.executeQuery();
					rs.next();
					%>
				<table>
					<tr>
						<th>Student ID</th>
						<th>First Name</th>
						<th>Middle Name</th>
						<th>Last Name</th>
						<th>SSN</th>
					</tr>
					<tr>
						<td><%= rs.getInt("STUDENT_ID") %></td>
						<td><%= rs.getString("FIRST_NAME") %></td>
						<td><%= rs.getString("MIDDLE_NAME") %></td>
						<td><%= rs.getString("LAST_NAME") %></td>
						<td><%= rs.getInt("SSN") %></td>
					</tr>
				</table>
					<%

					// get the degree_requirement_id for the student's degree
					pstmt = conn.prepareStatement("SELECT DEGREE_REQUIREMENT_ID from degree where STUDENT_ID = ? and DEGREE_NAME = ?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("STUDENT_ID")));
					pstmt.setString(2, request.getParameter("DEGREE_NAME"));
					rs = pstmt.executeQuery();
					int degree_requirement_id = 0;
					if(rs.next()){
						degree_requirement_id = rs.getInt("DEGREE_REQUIREMENT_ID");
					}
					else{
						// take best guess to get degree_requirement_id (should work)
						PreparedStatement pstmt2 = conn.prepareStatement("SELECT DEGREE_REQUIREMENT_ID from degree where DEGREE_NAME = ?");
						pstmt2.setString(1, request.getParameter("DEGREE_NAME"));
						ResultSet rs2 = pstmt2.executeQuery();
						rs2.next();
						degree_requirement_id = rs2.getInt("DEGREE_REQUIREMENT_ID");

						isTaking = false;
					}

					pstmt = conn.prepareStatement("SELECT * from course_category where DEGREE_REQUIREMENT_ID = ?");
					pstmt.setInt(1, degree_requirement_id);
					rs = pstmt.executeQuery();

					int numUnits = 0;
					// iterates over all categories required by the degree
					%>
					<!-- Part 3 DISPLAY MIN UNITS PER CATEGORY -->
				<table>
					<tr>
						<td>Category Name</td>
						<td>Units Required</td>
					</tr>
					<%
					while(rs.next()){
						numUnits+= rs.getInt("min_units");
						%>
					<tr>
						<td><%= rs.getString("NAME") %></td>
						<td><%= rs.getInt("MIN_UNITS") %></td>
					</tr>
						<%
					}
				%>
				</table>
				<!-- PART 2 DISPLAY Number of units required for degree -->
				<p>Total Num Units necessary: <%= numUnits %></p>
				
				<%
					// gets all course_category
					pstmt = conn.prepareStatement("SELECT * from course_category where DEGREE_REQUIREMENT_ID = ?");
					pstmt.setInt(1, degree_requirement_id);
					rs = pstmt.executeQuery();

					// for each course_category
					while(rs.next()){

						// gets all course_ids and its best grade which sataify the current requirement
						PreparedStatement pstmt2 = conn.prepareStatement("SELECT COURSE_ID, MIN(GRADE) as BEST from academic_history where COURSE_ID IN (SELECT COURSE_ID from fulfills where COURSE_CATEGORY_ID = ? and DEGREE_REQUIREMENT_ID = ?) GROUP BY COURSE_ID");
						pstmt2.setInt(1, rs.getInt("COURSE_CATEGORY_ID"));
						pstmt2.setInt(2, degree_requirement_id);
						ResultSet rs2 = pstmt2.executeQuery();

						//for each course taken that satisfies current requirement
						int counted = 0;
						while(rs2.next()){
							// get the units taken for that class 
							PreparedStatement pstmt3 = conn.prepareStatement("SELECT UNITS from academic_history where COURSE_ID = ? and GRADE = ?");
							pstmt3.setString(1, rs2.getString("COURSE_ID"));
							pstmt3.setString(2, rs2.getString("BEST"));
							rs3 = pstmt3.executeQuery();
							rs3.next();

							counted =+ rs3.getInt("UNITS");
						}
						if(isTaking){
						%>
							<p><%= rs.getString("NAME") %>: <%= rs.getInt("MIN_UNITS") - counted %> units left</p>
						<%
						}
						else{
						%>
							<p><%= rs.getString("NAME") %>: <%= rs.getInt("MIN_UNITS") %> units left</p>
						<%

						}
					}
					// end of processing if statement
				}


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
				</table>
				</td>
			</tr>
		</table>
	</body>
</html>
