-- against table OGH_TECHEXP17
-- session details for OGH_TECHEXP17 conference

DECLARE
  l_policy     VARCHAR2(30):='session_class_policy';
  l_preference VARCHAR2(30):='session_nb_lexer';
BEGIN
  BEGIN
    ctx_ddl.drop_policy(l_policy);
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  BEGIN
    ctx_ddl.drop_preference(l_preference);
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  ctx_ddl.create_preference(l_preference, 'BASIC_LEXER');
  ctx_ddl.create_policy(l_policy, lexer => l_preference);
END;


CREATE TABLE session_class_nb_settings
  (
    setting_name  VARCHAR2(30),
    setting_value VARCHAR2(4000)
  );


DECLARE
  l_policy     VARCHAR2(30):='session_class_policy';
BEGIN
  -- Populate settings table
  INSERT
  INTO session_class_nb_settings VALUES
    (
      dbms_data_mining.algo_name,
      dbms_data_mining.algo_naive_bayes
    );
  INSERT
  INTO session_class_nb_settings VALUES
    (
      dbms_data_mining.prep_auto,
      dbms_data_mining.prep_auto_on
    );
  INSERT
  INTO session_class_nb_settings VALUES
    (
      dbms_data_mining.odms_text_policy_name,
      l_policy
    ); 
/*  INSERT
  INTO plsql_nb_settings VALUES --
    (
      dbms_data_mining.NABS_PAIRWISE_THRESHOLD,
      0.01
    ); --
  INSERT
  INTO plsql_nb_settings VALUES --
    (
      dbms_data_mining.NABS_SINGLETON_THRESHOLD,
      0.01
    );
    */
  COMMIT;
END;


DECLARE
  xformlist dbms_data_mining_transform.TRANSFORM_LIST;
BEGIN
  BEGIN
    DBMS_DATA_MINING.DROP_MODEL('SESSION_CLASS_NB');
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  dbms_data_mining_transform.SET_TRANSFORM( xformlist, 'abstract', NULL, 'abstract', NULL, 'TEXT(TOKEN_TYPE:NORMAL)');
  DBMS_DATA_MINING.CREATE_MODEL( model_name => 'SESSION_CLASS_NB'
  , mining_function => dbms_data_mining.classification
  , data_table_name => 'OGH_TECHEXP17'
  , case_id_column_name => 'title'
  , target_column_name => 'track'
  , settings_table_name => 'session_class_nb_settings'
  , xform_list => xformlist);
END;
/



Test model 

SELECT title, 
  PREDICTION(SESSION_CLASS_NB USING *) AS predicted_target
  ,abstract
FROM OGH_TECHEXP17
where track is null


Against abstracts from Oracle Code London:

-- Oracle Code London
with sessions_to_judge as
( select 'The Modern JavaScript Server Stack' title
  , 'The usage of JavaScript on the server is rising, and Node.js has become popular with development shops, from startups to big corporations. With its asynchronous nature, JavaScript provides the ability to scale dramatically as well as the ability to drive server-side applications. There are a number of tools that help with all aspects of browser development: testing, packaging, and deployment. In this session learn about these tools and discover how you can incorporate them into your environment.' abstract
  from dual
  UNION ALL
  select 'Winning Hearts and Minds with User Experience' title
  , 'Not too long ago, applications could focus on feature functionality alone and be successful. Today, they must also be beautiful, responsive, and intuitive. In other words, applications must be designed for user experience (UX) because when they are, users are far more productive, more forgiving, and generally happier. Who doesnt want that? In this session learn about the psychology behind what makes a great UX, discuss the key principles of good design, and learn how to apply them to your own projects. Examples are from Oracle Application Express, but these principles are valid for any technology or platform. Together, we can make user experience a priority, and by doing so, win the hearts and minds of our users. We will use Oracle JET as well as ADF and some mobile devices and Java' abstract
  from dual
)
SELECT title, 
  PREDICTION(SESSION_CLASS_NB USING *) AS predicted_target
  ,abstract
FROM sessions_to_judge


as SYS:

grant execute on ctx_ddl to oow

GRANT create mining model TO oow;