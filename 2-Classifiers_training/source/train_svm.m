function [svm] = train_svm(positive_examples, negative_examples, config)
    % Ensure representations are of the same dimensionality.
    assert(size(positive_examples,1) == size(negative_examples,1));
    
    % Representation dimensions
    repr_dims = size(positive_examples,1);
    
    % Total examples.
    total_positive = size(positive_examples,2);
    total_negative = size(negative_examples,2);
    total_examples = total_positive + total_negative;

    % Training labels. Column vector with m rows.
    training_label_vector = ones([total_examples 1]);
    training_label_vector( total_positive+1:end, 1) = -1;
    
    % Training instances with n features. Each of the m rows has n
    % columns.
    training_instance_matrix = zeros([total_examples repr_dims]);
    
    training_instance_matrix( 1:total_positive, : ) = positive_examples';
    training_instance_matrix( (total_positive+1):end, : ) = negative_examples';
    
    
    % Train SVM.
    %fprintf('Training SVM... ');
   % start_time=clock;
    
    svm = svmtrain(training_label_vector, training_instance_matrix);
    
    %fprintf('Done in %4.2f secs.\n',etime(clock,start_time));
end

